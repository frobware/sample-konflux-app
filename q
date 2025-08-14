[33mcommit bbb490030f11049d6e261e5d57c2fb228b29531f[m[33m ([m[1;36mHEAD[m[33m -> [m[1;32mmain[m[33m)[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Thu Aug 14 12:39:30 2025 +0100

    Restore catalog directory with NetObserv-style simple Dockerfile
    
    Hybrid approach: keep catalog in main repo for nudging automation
    but use NetObserv-style simple Dockerfile that just copies
    pre-generated files instead of trying to generate at build time.
    
    This enables:
    - Automated nudging when bundle changes (via update_catalog.sh)
    - Reliable builds with distroless OPM base image
    - Pre-generated catalog files committed to git
    - Clean separation while maintaining automation

[33mcommit 6ca8f87453bb97390b4d918a5041d74eb744949b[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Thu Aug 14 12:37:19 2025 +0100

    Move catalog to separate repository following NetObserv pattern
    
    Remove all catalog-related files from main operator repository.
    Catalog functionality moved to sample-konflux-app-catalog repo
    for cleaner separation of concerns.
    
    This follows the NetObserv pattern where operator and catalog
    are maintained in separate repositories with different release
    cadences and responsibilities.

[33mcommit 2ea61609ece5a277b9588e2a8a8eb83e090dc570[m[33m ([m[1;31morigin/main[m[33m, [m[1;31morigin/HEAD[m[33m)[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Thu Aug 14 12:15:07 2025 +0100

    Implement autonomous catalog generation for CI builds
    
    Convert catalog.Dockerfile to generate catalog files at build time
    rather than depending on pre-generated files. This fixes CI build
    failures where auto-generated files were expected but not present.
    
    The autonomous approach reads bundle references from
    konflux/image-refs/bundle.txt and updates templates accordingly,
    following patterns used by other operators whilst maintaining
    separation of concerns for the catalog directory.

[33mcommit d2a4f669939f4fe8f5ed71d00fd18af3d9542509[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Thu Aug 14 11:52:35 2025 +0100

    Implement NetObserv-style template-based catalog system
    
    - Add template-based catalog generation using omp render-template
    - Create self-contained catalog/Makefile with local tool installation
    - Implement NetObserv-style build/push/deploy workflow for local testing
    - Add alpha and stable stream templates for multi-channel support
    - Update catalog nudging script to handle template-generated catalogs
    - Add proper .gitignore for auto-generated files and local tools
    - Support both podman and docker with podman preference
    - Create idempotent deploy/undeploy targets with image substitution
    
    Local testing workflow: make build-image push-image deploy

[33mcommit 0cf55aff6f892fe8f7cffefd3767590b959381a5[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Thu Aug 14 09:00:41 2025 +0100

    Replace legacy catalog format with proper File-Based Catalog (FBC)
    
    Convert from old olm.catalog format to modern FBC with separate package,
    channel and bundle schemas. Update build script to reference index.yaml
    instead of catalog.yaml.
    
    This provides better upgrade path management and aligns with OLM v1 standards.

[33mcommit ad4721541cc30bd73ad942eb5e9e39c86a0dcf78[m
Merge: 3329e0a ad325fe
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Thu Aug 14 08:41:36 2025 +0100

    Merge pull request #76 from frobware/konflux/component-updates/component-update-todoapp-operator
    
    Update todoapp-operator to e2463a7

[33mcommit ad325fed48b2c3bb41c1ec9b8a4aa437442eda93[m[33m ([m[1;31morigin/konflux/component-updates/component-update-todoapp-operator[m[33m)[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Thu Aug 14 07:30:51 2025 +0000

    Update todoapp-operator to e2463a7
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=3329e0a79060d51ee8f875c5b406c0f6ad43971a'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit 3329e0a79060d51ee8f875c5b406c0f6ad43971a[m
Merge: 6f14e3d 9ce32c8
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Thu Aug 14 08:27:41 2025 +0100

    Merge pull request #75 from frobware/konflux/mintmaker/main/golang-1.x
    
    Update golang Docker tag to v1.25

[33mcommit 9ce32c8271136c719d877174c906e1fd2b8c0dd2[m[33m ([m[1;31morigin/konflux/mintmaker/main/golang-1.x[m[33m)[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Thu Aug 14 00:13:32 2025 +0000

    Update golang Docker tag to v1.25
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit 6f14e3d0bf06f8ec4f1510c73ece32ec001b3b44[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 18:43:02 2025 +0100

    Revert "Fix catalog format to proper File-Based Catalog (FBC) format"
    
    This reverts commit d6df2cfd8ab8ad8cf4bcd2b84ba1e1999755ab39.

[33mcommit d6df2cfd8ab8ad8cf4bcd2b84ba1e1999755ab39[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 18:41:48 2025 +0100

    Fix catalog format to proper File-Based Catalog (FBC) format
    
    Convert catalog.yaml from simplified format to proper FBC format with:
    - olm.catalog schema
    - olm.package definition with defaultChannel
    - olm.channel with proper entries
    - olm.bundle with properties and GVK information
    
    This should resolve the packagemanifest issue preventing the operator
    from appearing in the OpenShift Operator Hub.

[33mcommit dcfe4630d582e1fbc288d02e937baa73332b9502[m
Merge: d863dbf 53ec3e6
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Wed Aug 13 17:32:45 2025 +0100

    Merge pull request #74 from frobware/konflux/component-updates/component-update-todoapp-bundle
    
    Update todoapp-bundle to adaae1b

[33mcommit 53ec3e65b2fd45446863f6c5886dee71897f15a7[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Wed Aug 13 16:28:41 2025 +0000

    Update todoapp-bundle to adaae1b
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=d863dbfd286d441fd7be4f5a4f12af519a2196b8'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit d863dbfd286d441fd7be4f5a4f12af519a2196b8[m
Merge: 0a570ba d04cd46
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Wed Aug 13 17:27:02 2025 +0100

    Merge pull request #73 from frobware/konflux/component-updates/component-update-todoapp-operator
    
    Update todoapp-operator to 74dbcb1

[33mcommit d04cd46f9503721dd6f4db6f5264e35d9cf4b405[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Wed Aug 13 16:23:57 2025 +0000

    Update todoapp-operator to 74dbcb1
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=0a570ba7692f15943cfb4d17bce6a172d11f1e3a'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit 0a570ba7692f15943cfb4d17bce6a172d11f1e3a[m
Merge: cba6de1 3ddbc47
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Wed Aug 13 17:21:28 2025 +0100

    Merge pull request #72 from frobware/feature/enhance-todoapp-operator
    
    Test Konflux component nudging workflow

[33mcommit 3ddbc47b0049371245ff20263fe5fcd6f985431d[m[33m ([m[1;31morigin/feature/enhance-todoapp-operator[m[33m, [m[1;32mfeature/enhance-todoapp-operator[m[33m)[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 17:17:06 2025 +0100

    Add timestamp comment to test Konflux nudging workflow
    
    This change adds a simple timestamp comment to the TodoApp types file
    to trigger the operator build pipeline and test the component nudging
    workflow: operator -> bundle -> catalog.

[33mcommit cba6de17b6092021378e95019efde60bc8ba607e[m
Merge: 635bcc6 03e3794
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Wed Aug 13 17:10:15 2025 +0100

    Merge pull request #71 from frobware/konflux/component-updates/component-update-todoapp-bundle
    
    Update todoapp-bundle to 57dbdc8

[33mcommit 03e379436d3c23d925bcbad1265d2f91af5411f5[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Wed Aug 13 16:03:20 2025 +0000

    Update todoapp-bundle to 57dbdc8
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=635bcc61bd52e21b2b1bca63739d888fa3a40a90'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit 635bcc61bd52e21b2b1bca63739d888fa3a40a90[m
Merge: 9460d4c 935b5c9
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Wed Aug 13 17:01:28 2025 +0100

    Merge pull request #70 from frobware/konflux/component-updates/component-update-todoapp-operator
    
    Update todoapp-operator to 1b6d944

[33mcommit 935b5c96ca481e1de64351751edde752c8d4c3dd[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Wed Aug 13 15:57:07 2025 +0000

    Update todoapp-operator to 1b6d944
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=9460d4cc9bec32727534ca0a2562c425f2a6c865'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit 9460d4cc9bec32727534ca0a2562c425f2a6c865[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 16:54:18 2025 +0100

    dummy change

[33mcommit efc20ced552f5780c239f8be725864b27686c874[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 16:44:40 2025 +0100

    Disable hermetic builds and enable skip-checks for catalog component
    
    The catalog pipeline was failing due to conflicts between the built-in
    OPM image replacement step and our custom update_catalog.sh script that
    already handles image reference updates during the Docker build process.
    
    Changes:
    - Set hermetic: false to allow network access during build
    - Set skip-checks: true to bypass problematic validation steps
    - Applied to both push and pull-request pipelines for consistency
    
    This should allow the catalog build to complete successfully whilst
    maintaining our custom image reference management approach.

[33mcommit 020c2bf3488f498ba9f423703925e14aa5f88d05[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 16:31:13 2025 +0100

    Refine Dockerfiles to use WORKDIR first with cleaner COPY syntax
    
    Set WORKDIR /repo first, then use COPY . . for cleaner, more natural syntax
    whilst maintaining container isolation from base image files.
    
    Changes:
    - Bundle/catalog Dockerfiles: WORKDIR /repo before COPY . .
    - Keeps clean isolation in /repo directory
    - Natural copy syntax instead of COPY . /repo
    - Scripts continue to work identically in containers and locally
    - Multi-stage COPY commands use /repo/ absolute paths as required
    
    Verified: All three containers build successfully with proper image reference
    updates during build process.

[33mcommit 2f2b6a7d4458b6a09130f91312b280cf2876754e[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 16:24:09 2025 +0100

    Simplify Dockerfiles and scripts to use natural relative paths
    
    Remove unnecessary /repo intermediate directories and path complexity.
    Scripts now work identically whether run locally or in containers.
    
    Changes:
    - Bundle/catalog Dockerfiles: COPY . . instead of COPY . /repo
    - Remove WORKDIR /repo (use container root directory)
    - Scripts use same relative paths as work locally
    - COPY --from=builder bundle/... instead of /repo/bundle/...
    
    Result: Ultra-clean, minimal Dockerfiles with scripts that work the same
    everywhere. No path translation or container-specific modifications needed.

[33mcommit 60a91ddfef8eff11e0c11e88bc128bb921b09cb1[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 16:19:23 2025 +0100

    Fix Dockerfiles and scripts to execute update scripts during container builds
    
    Update both bundle and catalog Dockerfiles to properly execute update scripts
    during the container build process, following the pattern from bpfman-operator.
    
    Bundle changes:
    - Use multi-stage build with UBI minimal for script execution
    - Copy scripts and files to /tmp/ with absolute paths
    - Execute update_bundle.sh to replace controller:latest with real operator image
    - Copy updated files to final scratch image
    
    Catalog changes:
    - Use multi-stage build with UBI minimal for shell support
    - Execute update_catalog.sh to replace bundle:latest with real bundle digest
    - Use OPM image for final catalog processing and serving
    
    Script path fixes:
    - Update file paths in both scripts to match container layout
    - Use /tmp/konflux/image-refs/ and /tmp/bundle/ or /configs/ paths
    - Maintain brutal error handling and validation
    
    This completes the nudging workflow - container images now contain correct
    image references instead of placeholder values, enabling proper cascading
    component updates.

[33mcommit d255a35e4db84c5670c384198ffbe5b47604120e[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 14:57:25 2025 +0100

    Enhance catalog update script with robust validation and error handling
    
    Add comprehensive validation to update_catalog.sh matching the bundle script
    approach. The script now validates input files exist, checks for empty bundle
    references, verifies expected image patterns are found before attempting
    updates, confirms updates succeeded, and ensures the new image reference is
    present in the updated catalog file.
    
    Fix catalog file path to use the correct location at catalog/catalog.yaml
    rather than the incorrect catalog/todoapp-operator/catalog.yaml path.
    
    The script now fails fast and clearly when any part of the catalog update
    process encounters issues, ensuring build failures are caught early with
    clear error messages.

[33mcommit 55d6f0d12e59fe025ee2bda66587bcab16af935d[m
Merge: 3053dc2 832be9c
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Wed Aug 13 15:02:52 2025 +0100

    Merge pull request #67 from frobware/konflux/component-updates/component-update-todoapp-bundle
    
    Update todoapp-bundle to 3bc5d02

[33mcommit 3053dc2938967959e29d1a397a049f191d243c1f[m
Merge: e88e1a8 6a1651e
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Wed Aug 13 14:58:00 2025 +0100

    Merge pull request #66 from frobware/konflux/component-updates/component-update-todoapp-operator
    
    Update todoapp-operator to 5646310

[33mcommit 832be9cea5d5e9f040c40c8457240c7c2fd790dc[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Wed Aug 13 13:54:56 2025 +0000

    Update todoapp-bundle to 3bc5d02
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=e88e1a8fde190a006298d13330ae5404eba3bca8'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit 6a1651ebedbe95ba137fa4ae294c34994ffe326c[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Wed Aug 13 13:53:01 2025 +0000

    Update todoapp-operator to 5646310
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=6703534b2e9d9de12b0fc3f861443027b861d190'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit e88e1a8fde190a006298d13330ae5404eba3bca8[m
Merge: 6703534 d34b533
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Wed Aug 13 14:52:48 2025 +0100

    Merge pull request #65 from frobware/konflux/component-updates/component-update-todoapp-operator
    
    Update todoapp-operator to 128c9eb

[33mcommit 6703534b2e9d9de12b0fc3f861443027b861d190[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 14:49:37 2025 +0100

    Fix CEL expressions to remove incorrect cross-component dependencies
    
    Remove spurious triggers where components were rebuilding based on other
    components' scripts. Each component should only trigger on changes to its own
    files and scripts, plus image reference changes for nudging.
    
    - Bundle no longer triggers on catalog script changes
    - Operator no longer triggers on bundle script changes
    - Maintains proper nudging triggers for image reference updates
    
    This ensures builds only occur when actually needed and makes the dependency
    logic clear and maintainable.

[33mcommit d34b5339ca615593293f246c6feb07b8e397e059[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Wed Aug 13 13:48:40 2025 +0000

    Update todoapp-operator to 128c9eb
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=e942b471e3d952f4873faaf7731529c4443cccef'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit e942b471e3d952f4873faaf7731529c4443cccef[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 14:42:45 2025 +0100

    Enhance bundle update script with robust validation and error handling
    
    Clean up operator image reference file to contain only the image URL without
    comments or extra lines. Add comprehensive validation to update_bundle.sh to
    ensure the script fails fast and clearly when any part of the bundle update
    process fails, including missing files, empty references, failed substitutions,
    or missing expected image patterns.
    
    The script now validates input files exist, checks for empty references,
    verifies expected image patterns are found before attempting updates, confirms
    updates succeeded, and ensures the new image reference is present in the
    updated file.

[33mcommit ef625e1e4b326c6aa56e5ad62aeac33be1f328e5[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 14:31:53 2025 +0100

    Add bundle image-refs trigger to catalog pull-request pipeline
    
    Catalog PRs should validate compatibility when bundle image references
    change. This ensures update_catalog.sh runs and the catalog can correctly
    use the new bundle image before merging nudge PRs.

[33mcommit d3a5797c891e39ed4d0b3fadbf89a6df091f1fa6[m
Merge: 18d65b5 dafda5e
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Wed Aug 13 14:30:44 2025 +0100

    Merge pull request #63 from frobware/konflux/component-updates/component-update-todoapp-operator
    
    Update todoapp-operator to 7683b59

[33mcommit dafda5e892f6bcbd4edd56cab04b2d3a219e8155[m[33m ([m[1;32mkonflux/component-updates/component-update-todoapp-operator[m[33m)[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Wed Aug 13 13:21:50 2025 +0000

    Update todoapp-operator to 7683b59
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=3f080cb2e3fd9ac64f4e5e13f40a5dc60f4309fb'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit 18d65b57262f5d2cf57c50fc46d045383f9905bf[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 14:26:10 2025 +0100

    Add operator image-refs trigger to bundle pull-request pipeline
    
    Bundle PRs should validate compatibility when operator image references
    change. This ensures update_bundle.sh runs and the bundle can correctly
    use the new operator image before merging nudge PRs.

[33mcommit 9212c656eac2c474f723d45002c17e9a4d458a8e[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 14:21:18 2025 +0100

    Cleanup konflux/image-refs/operator.text

[33mcommit 3f080cb2e3fd9ac64f4e5e13f40a5dc60f4309fb[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 14:19:08 2025 +0100

    Add internal/doc.go to test operator nudging cascade
    
    Created doc.go with change log for testing the complete Konflux
    nudging workflow. This genuine operator code change should trigger:
    1. Operator pipeline build
    2. Bundle nudge PR creation
    3. Catalog nudge PR after bundle merge
    
    This validates the full operator → bundle → catalog cascade.

[33mcommit 32059ebf6092dbb264d22c6b144a5d7a035af859[m
Merge: 335583d d40dc31
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Wed Aug 13 14:14:55 2025 +0100

    Merge pull request #62 from frobware/konflux/component-updates/component-update-todoapp-bundle
    
    Update todoapp-bundle to 8a27837

[33mcommit d40dc31ddef93332e268bb3833e38c7abf5f453c[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Wed Aug 13 13:11:08 2025 +0000

    Update todoapp-bundle to 8a27837
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=335583d93985464b0102fe5ccb4210615ff3ec0e'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit 335583d93985464b0102fe5ccb4210615ff3ec0e[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 14:09:07 2025 +0100

    Remove image-refs from pull-request pipeline triggers
    
    Pull-request pipelines should not trigger on image reference changes
    because PRs are proposals, not merged changes. Building downstream
    components based on unmerged dependency changes wastes CI resources
    and doesn't make logical sense.
    
    Only push pipelines should trigger on image-refs changes since those
    represent actual merged dependency updates.

[33mcommit bdcde72add6cd10fd7139f5d93d0b1ac8fe1b34e[m
Merge: 19de5a2 843ebfb
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Wed Aug 13 14:00:19 2025 +0100

    Merge pull request #61 from frobware/konflux/component-updates/component-update-todoapp-operator
    
    Update todoapp-operator to 61ec794

[33mcommit 19de5a23d7e49c7e49e83b7e91b16019b29170fc[m
Merge: 7042b70 269cab2
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Wed Aug 13 14:00:13 2025 +0100

    Merge pull request #60 from frobware/konflux/component-updates/component-update-todoapp-bundle
    
    Update todoapp-bundle to 27b8190

[33mcommit 843ebfb7cf0fac6f038b6e74f88b3811ea6e6052[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Wed Aug 13 12:35:23 2025 +0000

    Update todoapp-operator to 61ec794
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=51653c130885ea00fab0a4a5e55e87d941a9f9e0'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit 269cab21416e31c8506208a5a915f7e902d2f169[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Wed Aug 13 12:34:32 2025 +0000

    Update todoapp-bundle to 27b8190
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=51653c130885ea00fab0a4a5e55e87d941a9f9e0'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit 7042b70be212c98a74beba7d5429e384d90031bf[m
Merge: 51653c1 6f22736
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Wed Aug 13 13:33:46 2025 +0100

    Merge pull request #59 from frobware/konflux/component-updates/component-update-todoapp-operator
    
    Update todoapp-operator to 128a7a9

[33mcommit 51653c130885ea00fab0a4a5e55e87d941a9f9e0[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 13:32:52 2025 +0100

    Fix overly broad pull-request pipeline triggers
    
    Updated all three pull-request pipelines to use specific path-based
    triggers instead of triggering on any PR to main. This prevents
    unnecessary builds when PRs don't affect the relevant component.
    
    - todoapp-operator-pull-request: Only triggers on operator-related changes
    - todoapp-bundle-pull-request: Only triggers on bundle/operator changes
    - todoapp-catalog-pull-request: Only triggers on catalog/bundle changes
    
    This matches the behaviour of the corresponding push pipelines.

[33mcommit 6f227366289bc280a4ad1c10f74da133884a4121[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Wed Aug 13 12:02:50 2025 +0000

    Update todoapp-operator to 128a7a9
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=0a78bc9c3f958d705278acfe053105c2820dd9c7'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit 0a78bc9c3f958d705278acfe053105c2820dd9c7[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 13:00:03 2025 +0100

    Test operator pipeline after bundle_tmp removal
    
    Trigger operator pipeline to verify that symlink check now passes
    after properly removing the bundle_tmp directory with problematic
    symlinks from the git repository.

[33mcommit 3a93caff7ebe6d2172bd70822cea3a37bc159695[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 12:57:45 2025 +0100

    Actually remove bundle_tmp directory with problematic symlinks
    
    The bundle_tmp directory contains symlinks that cause Konflux symlink
    security checks to fail. This commit properly removes all files in the
    bundle_tmp691163984 directory from git tracking.

[33mcommit 11f2f0303fc0a1a83f1a64c8f8ecf21e3972bf2b[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 12:55:05 2025 +0100

    Force sync: ensure bundle_tmp directory is completely removed
    
    This empty commit forces a new commit hash to ensure
    GitHub reflects the current state without bundle_tmp files.

[33mcommit c68098e25e6fe1d6c888e0f4df5a179f0a48a38a[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 12:42:10 2025 +0100

    Force trigger operator pipeline after bundle_tmp removal
    
    Added comment to cmd/main.go to ensure operator pipeline is triggered
    after removing the bundle_tmp directory that contained problematic
    symlinks causing Konflux security check failures.

[33mcommit 696aa4ceb433b22d390e241b274a0ee46dc81d9d[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 12:38:16 2025 +0100

    Clean up temporary file

[33mcommit 79f4bec4633a70028b49a0efc4fe5a362d9b2682[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 12:38:10 2025 +0100

    Remove bundle_tmp directory and add .gitignore entry
    
    The bundle_tmp directory was accidentally committed during operator-sdk
    rebuild and contains symlinks pointing to absolute paths, causing
    Konflux symlink security checks to fail. Added bundle_tmp* to .gitignore
    to prevent future accidental commits of temporary directories.

[33mcommit 040f538da0bbd962895e7c00dc9733796bcab480[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 12:21:25 2025 +0100

    Trigger operator pipeline rebuild
    
    Add comment to main.go to trigger operator pipeline rebuild
    since the previous symlink fix commit only modified the image
    reference file which doesn't trigger operator rebuilds.

[33mcommit 4a8a3edf3f4db21fa19e22a89ad4247e76473a4a[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 12:19:06 2025 +0100

    Fix symlink issues causing pipeline failures
    
    Remove problematic symlinks that pointed outside repository
    directory structure, which caused Konflux symlink security
    checks to fail during the git-clone step.

[33mcommit 468d1e8e089cc80202e89f8e08843cd6b8502a10[m[33m ([m[1;32moperator-sdk-rebuild[m[33m)[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 12:08:11 2025 +0100

    Rebuild project with operator-sdk and consolidate Konflux assets
    
    Complete rebuild of the Kubernetes operator using operator-sdk instead of
    Kubebuilder to provide proper OLM integration with bundle and catalog
    generation capabilities. Consolidate all Konflux-specific assets under a
    centralised directory structure whilst preserving CI/CD automation.
    
    Key changes:
    - Rebuild entire project using operator-sdk init for proper OLM support
    - Consolidate Konflux assets under konflux/ directory (scripts, image-refs)
    - Generate proper OLM bundle with operator-sdk bundle command
    - Add complete Makefile with bundle and catalog build targets
    - Update Dockerfile to use Go 1.23 and distroless base image
    - Remove redundant Dockerfiles in favour of operator-sdk generated ones
    - Update .tekton pipelines to reference top-level Dockerfiles
    - Live-patch components to use new Dockerfile paths
    - Generate file-based catalog structure for modern OLM deployment
    
    The operator builds successfully and runs properly, though it currently
    implements only a basic scaffold. The Konflux CI/CD pipeline remains
    fully functional with the restructured assets.

[33mcommit 5c82927b7f1a9c2bd0df577440894d8113a6eb32[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 11:27:50 2025 +0100

    Consolidate Konflux assets under konflux/ directory
    
    Reorganise all Konflux-specific components into a centralised directory
    structure for better separation of platform concerns from application
    logic. This consolidation makes the repository cleaner and easier to
    maintain.
    
    Changes:
    - Move scripts: bundle-hack/ and catalog-hack/ → konflux/scripts/
    - Move Dockerfiles: *.Dockerfile → konflux/dockerfiles/
    - Move image references: image-refs/ → konflux/image-refs/
    - Update all .tekton pipeline definitions with new paths
    - Update component manifests with new Dockerfile locations
    - Update CEL expressions to watch new directory paths
    - Update live components via oc patch for immediate effect
    
    The new struktur provides clear separation between core application
    code and platform-specific Konflux requirements, whilst maintaining
    all existing functionality.

[33mcommit 0283308bd90334f0ada746e156a54b3849af3ee7[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Wed Aug 13 11:28:32 2025 +0100

    Update todoapp-operator to 3607b34 (#58)
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=ddcc42a28dc35bfc34fbdce3adb147c3844b067f'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>
    Co-authored-by: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit ddcc42a28dc35bfc34fbdce3adb147c3844b067f[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 11:02:41 2025 +0100

    Refactor nudging to use centralised image references
    
    Create image-refs/ directory to centralise container image references
    rather than embedding them directly in shell scripts. This approach
    provides cleaner separation of concerns and makes image references
    easily accessible for tooling like podman and skopeo.
    
    Changes:
    - Create image-refs/operator.txt and image-refs/bundle.txt files
    - Update bundle-hack/update_bundle.sh to source from image-refs/operator.txt
    - Update catalog-hack/update_catalog.sh to source from image-refs/bundle.txt
    - Update build-nudge-files annotations to reference the text files directly
    - Remove test file bundle-hack/foo.txt
    
    The nudging mechanism will now update the centralised image reference
    files, and all scripts that source from them will automatically use
    the updated references.

[33mcommit 559bbccb1495c94c0ca5b692d25fa8bee3254822[m
Merge: 1aed728 808f6e0
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Wed Aug 13 10:53:55 2025 +0100

    Merge pull request #55 from frobware/konflux/component-updates/component-update-todoapp-operator
    
    Update todoapp-operator to 0f82f92

[33mcommit 1aed7282965b6c8ddb6d0fa43cae06576b2d9a35[m
Merge: 2f73457 c0b51bd
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Wed Aug 13 10:53:40 2025 +0100

    Merge pull request #54 from frobware/konflux/component-updates/component-update-todoapp-bundle
    
    Update todoapp-bundle to acb636b

[33mcommit 808f6e058354b1be61c77a68c33c552aa9029193[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Wed Aug 13 08:48:03 2025 +0000

    Update todoapp-operator to 0f82f92
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=2f7345767a9a2d010bb9b86c4db23ac256a274d9'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit c0b51bd83a67f44e45514f896ac195ebb2317fb7[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Wed Aug 13 08:47:15 2025 +0000

    Update todoapp-bundle to acb636b
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=2f7345767a9a2d010bb9b86c4db23ac256a274d9'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit 2f7345767a9a2d010bb9b86c4db23ac256a274d9[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Wed Aug 13 09:45:02 2025 +0100

    Test nudging behaviour with plain text file
    
    Add bundle-hack/foo.txt containing an image reference to test whether
    the nudging mechanism updates plain text files alongside shell scripts.
    Update the build-nudge-files annotation to include the new file and
    add a test change to internal/doc.go to trigger the pipeline.

[33mcommit 19343b2aead4dd781862307592daf40e3d1623de[m
Merge: 71b3bb4 7a59436
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Tue Aug 12 21:33:42 2025 +0100

    Merge pull request #53 from frobware/konflux/component-updates/component-update-todoapp-operator
    
    Update todoapp-operator to 793888b

[33mcommit 71b3bb4b3c00212a8e45f9e8c2d31eb6bbc38358[m
Merge: 5be5e34 e8e3dff
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Tue Aug 12 21:33:32 2025 +0100

    Merge pull request #52 from frobware/konflux/component-updates/component-update-todoapp-bundle
    
    Update todoapp-bundle to 50c0d2e

[33mcommit e8e3dffd4daf6afd33deeb8c2258d5a46fffcc67[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Tue Aug 12 15:04:05 2025 +0000

    Update todoapp-bundle to 50c0d2e
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=5be5e34efb5ddd278d1eaa03f034feded9db85db'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit 5be5e34efb5ddd278d1eaa03f034feded9db85db[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 16:02:10 2025 +0100

    Make catalog script regex pattern more specific
    
    Change the regex pattern from todoapp.*bundle to todoapp-bundle to ensure
    we only match the specific todoapp-bundle component and avoid potential
    matches with todoapp-operator-bundle or similar variations.

[33mcommit 7a594366c893ec76245297efe8e2466d0774e2e7[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Tue Aug 12 14:52:36 2025 +0000

    Update todoapp-operator to 793888b
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=a582ef77f90e8d83585f8798af6aba6c4219542c'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit a582ef77f90e8d83585f8798af6aba6c4219542c[m
Merge: 79bac3a 7889d44
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Tue Aug 12 15:49:57 2025 +0100

    Merge pull request #51 from frobware/konflux/component-updates/component-update-todoapp-operator
    
    Update todoapp-operator to 05af0bb

[33mcommit 79bac3a9bd9bb6000cf1a158aa9bfad6897b96f7[m
Merge: 475f70f 77dba91
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Tue Aug 12 15:49:53 2025 +0100

    Merge pull request #50 from frobware/konflux/component-updates/component-update-todoapp-bundle
    
    Update todoapp-bundle to 351e8c9

[33mcommit 77dba91627ca222416e4bfb8b645bcee06bf5459[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Tue Aug 12 14:47:32 2025 +0000

    Update todoapp-bundle to 351e8c9
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=475f70faebc09ed8395620720bc8bfa1dfde47d9'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit 475f70faebc09ed8395620720bc8bfa1dfde47d9[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 15:45:49 2025 +0100

    Fix catalog bundle image reference and update script pattern
    
    Update catalog.yaml to reference correct bundle component name and current
    image digest. Modify update script pattern to match both todoapp-bundle
    and todoapp-operator-bundle naming variations to ensure nudging works
    correctly.
    
    This should resolve the catalog pipeline validation failures.

[33mcommit 7889d44422a66841cd0351de80f0fb858b7018e6[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Tue Aug 12 14:36:15 2025 +0000

    Update todoapp-operator to 05af0bb
    
    Image created from 'https://github.com/frobware/sample-konflux-app?rev=741ca509c55d2c906a0cfbc34afda52231b26c6c'
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit 741ca509c55d2c906a0cfbc34afda52231b26c6c[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 15:33:37 2025 +0100

    Bootstrap nudging scripts with real image digests for Renovate detection

[33mcommit eb00fefacfe77f775ece010d69c79c355b03d458[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 15:28:35 2025 +0100

    Improve regex patterns and add detailed documentation to nudging scripts

[33mcommit cd9a7dbab48bc50251ffc2102de36cd03e42ff10[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 15:20:56 2025 +0100

    Update nudging scripts to use hardcoded image references for Renovate compatibility

[33mcommit 3416ab4c1f4085b1216278ad3ff45cc1812464b6[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 15:04:24 2025 +0100

    Test nudging workflow with annotations in place

[33mcommit 6ac8a63612f2a0dd9feaf420f386f9450dd7e5d6[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 14:59:51 2025 +0100

    Add nudging annotations to enable operator → bundle → catalog chain

[33mcommit 346b87cf6b32635cafb61b5e42a707c05d6f039a[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 14:55:34 2025 +0100

    Test operator-only change for nudging workflow

[33mcommit 9239d82371473b299fc2dc822c86b7838123a928[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 14:50:57 2025 +0100

    Add comprehensive CEL path filtering and remove patch files.
    
    Apply CEL expressions to filter pipeline builds by changed paths:
    - Operator: triggers on api/**, internal/**, cmd/**, config/**, bundle-hack/**
    - Bundle: triggers on bundle/**, bundle-hack/**, catalog-hack/**
    - Catalog: triggers on catalog/**, catalog-hack/**
    
    Remove patch files directory - git history provides better source of truth
    for reproducing configuration changes.

[33mcommit 81d59446ae56e0d92d1c9fe9746e41f046a67171[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 14:43:53 2025 +0100

    Apply skip-checks optimisation to all pipeline files.
    
    Set skip-checks parameter default to "true" for faster builds during testing.
    Remove broken individual patch files and replace with working combined patch.
    The skip-checks-applied.patch can be used to reapply these changes in future.

[33mcommit 2d676fbc29b7d23cc66184fb6fc32770b1bbc083[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Tue Aug 12 14:41:05 2025 +0100

    Red Hat Konflux update todoapp-operator (#49)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit 22f530908a474b1f4c14954a50607e67ff0a8e2c[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Tue Aug 12 14:41:03 2025 +0100

    Red Hat Konflux update todoapp-catalog (#48)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit 794002767914d3e243671a3b56b0ea487083f6bd[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Tue Aug 12 14:41:00 2025 +0100

    Red Hat Konflux update todoapp-bundle (#47)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit 6085be5c0265bcb0c5f38cd1f88c38a60c482da7[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 14:32:28 2025 +0100

    Split manifests into app and components subdirectories.
    
    Separate application manifest from component manifests for clearer
    organisation. Application creation and component creation are now
    distinct operations with their own directories.

[33mcommit bd9824f1e2230aaf6a7c9d66866f7030f04624de[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 14:28:35 2025 +0100

    Reorganise Konflux configuration into structured directory layout.
    
    Replace complex automation scripts with focused patch files. Move component
    manifests to konflux/manifests/ and organise patches by functionality into
    konflux/patches/cel/ and konflux/patches/skip-checks/. This provides a cleaner
    approach with simple YAML files for component creation and targeted patches
    for configuration after PAC PRs merge.

[33mcommit 67b93f56ffb1865504ac226d37aeead34a712b87[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 14:18:41 2025 +0100

    Split component management into separate delete and create scripts
    
    - delete-components.sh: Clean deletion with purge PR detection
    - create-components.sh: Component creation with nudging verification
    - Removed combined reset-components.sh for better control
    - Each script handles prerequisites and provides clear next steps
    
    This provides better granular control over the component lifecycle.

[33mcommit ec9313eed00dd089d8bcf51237a3c0fd1051149e[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 14:15:55 2025 +0100

    Add nudging automation scripts and comprehensive workflow documentation
    
    - setup-nudging.sh: Automates PR management and pipeline configuration
    - reset-components.sh: Provides clean component deletion/recreation
    - verify-nudging.sh: Comprehensive verification of nudging setup
    - NUDGING-WORKFLOW.md: Complete documented workflow with manual steps
    
    These scripts automate the repeatable parts of Konflux nudging setup
    while documenting the required manual interventions.

[33mcommit 841eb9884064e3b29133d12b69ae38492a9f9f21[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Tue Aug 12 14:30:30 2025 +0100

    Red Hat Konflux purge todoapp-bundle (#41)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit e3ff5e79ed419d2977e1dc16b6f785717f13e6bd[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Tue Aug 12 14:30:21 2025 +0100

    Red Hat Konflux purge todoapp-catalog (#42)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit 66dcf9fb95ccf5225d07a2691fd6e4d96b760e1d[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Tue Aug 12 14:30:11 2025 +0100

    Red Hat Konflux purge todoapp-operator (#43)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit 71e6bc09cc93d32a11d0f4764b0382c601a34f4d[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Tue Aug 12 14:09:59 2025 +0100

    Red Hat Konflux update todoapp-catalog (#37)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit cd972e418fdec92bbfd1e35cc7ba7e7a5c134bef[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Tue Aug 12 14:09:57 2025 +0100

    Red Hat Konflux update todoapp-bundle (#36)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit f4e1525c4f60f0a1f0c7645159126161b64e3ba6[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Tue Aug 12 14:09:54 2025 +0100

    Red Hat Konflux update todoapp-operator (#35)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit 8cf08040a1ed18c0d20cc5062d1e85aa95a2ee29[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 12:46:58 2025 +0100

    Configure component nudging relationships for automated operator → bundle → catalog workflow
    
    Add build-nudges-ref specifications to establish dependency chain:
    - todoapp-operator nudges todoapp-bundle
    - todoapp-bundle nudges todoapp-catalog
    
    Fix build-nudge-files annotations:
    - Bundle component now uses catalog-hack/update_catalog.sh script
    - Catalog component removes nudge-files (end of chain)
    
    This completes the automated nudging configuration where operator builds
    trigger bundle updates, which trigger catalog updates via pull requests.

[33mcommit 60d54a8fce12319fb6b49fb37b23cb4da6132320[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 12:30:42 2025 +0100

    Fix bundle update script to handle multiple image references correctly
    
    The ClusterServiceVersion contains both an example image reference in the
    alm-examples JSON section and the actual operator image in the deployment
    specification. Updated the sed pattern to target only the deployment
    section to avoid modifying the example.
    
    Pattern changed from simple wildcard to targeted replacement within the
    deployments section, preventing accidental updates to example images.

[33mcommit 16d80340d697efe88e41d90ed9cc1ea3483a920f[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 12:27:21 2025 +0100

    Add automated component nudging for operator → bundle → catalog workflow
    
    Configure build-nudge-files annotations to automatically update downstream
    components when upstream images change:
    
    - Operator builds trigger bundle updates via bundle-hack/update_bundle.sh
    - Bundle builds trigger catalog updates via catalog-hack/update_catalog.sh
    
    Improve environment variable naming with component-specific conventions:
    - TODOAPP_OPERATOR_IMAGE_DIGEST/URL for operator component
    - TODOAPP_BUNDLE_IMAGE_DIGEST/URL for bundle component
    
    Fix replacement logic to handle both initial setup and subsequent updates
    with flexible pattern matching instead of brittle exact string matches.
    
    Enhanced CEL expressions to include hack directories in build triggers
    for efficient build filtering.

[33mcommit 6025687ceea677ab34e9ea442259db73ddaa837c[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 12:11:25 2025 +0100

    Remove catalog/doc.go that was causing opm validation errors
    
    The omp validate command expects only YAML files in the catalog
    directory and was failing to parse the Go file as YAML.

[33mcommit 47b9f97bd0975d0618b14fe5fcfa71943b3f2540[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 12:07:39 2025 +0100

    Add skip-checks parameter to catalog pipeline files
    
    This change should trigger only the catalog pipeline due to CEL
    filtering on .tekton/todoapp-catalog-*.yaml files changing.
    This will also give us clean builds without validation warnings.

[33mcommit 65cd99d84712617a372a03f326d8e60227080558[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 12:05:38 2025 +0100

    Add catalog/doc.go for CEL filtering tests
    
    This catalog-only change should trigger only the catalog pipeline
    due to CEL expression filtering on catalog/*** path changes.

[33mcommit 69d0fa99460f47e5a8cdb7e152b1e2c51298bf1d[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 12:00:32 2025 +0100

    Add bundle/doc.go for CEL filtering tests
    
    This bundle-only change should trigger only the bundle pipeline
    due to CEL expression filtering on bundle/*** path changes.

[33mcommit 17d9d81788712becf2d33e94a601e10435e1abd6[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 11:55:00 2025 +0100

    Add skip-checks parameter to operator pipeline files
    
    This change should trigger only the operator pipeline due to CEL
    filtering on .tekton/todoapp-operator-*.yaml files changing.

[33mcommit 9e18ebd15f7f5c3ed911d5557dcea6dc48e4ade9[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 11:50:26 2025 +0100

    Add internal/doc.go for CEL filtering tests
    
    This operator-only change should trigger only the operator pipeline
    due to CEL expression filtering on internal/*** path changes.

[33mcommit 7acd8b06643f26f24e83f12cdea74c51009b2cbf[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 11:44:21 2025 +0100

    Test operator-only change: update controller comment
    
    This change only affects internal/controller/ files and should only
    trigger operator builds due to CEL expression filtering.

[33mcommit aae4372c321ebb18b51627f8d3385e15a9789153[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 11:42:50 2025 +0100

    Add path-based CEL expressions to pipeline files for optimized builds
    
    Configure CEL expressions to filter builds based on changed files:
    - Operator builds trigger only for operator-related changes
    - Bundle builds trigger only for bundle-related changes
    - Catalog builds trigger only for catalog-related changes
    
    This reduces unnecessary builds and improves CI resource utilization.

[33mcommit b6e4520af7d3ffecf66b9c25bead7b7a9beaebed[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Tue Aug 12 11:17:35 2025 +0100

    Red Hat Konflux update todoapp-catalog (#28)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit 6e3758d8c8b5db46e36adbc7408440a352285e75[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Tue Aug 12 10:36:41 2025 +0100

    Red Hat Konflux update todoapp-bundle (#23)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit c6f885c881c69a5f6e1608737c7c6f70f40c0a34[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Tue Aug 12 10:33:06 2025 +0100

    Red Hat Konflux update todoapp-operator (#22)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit 06388fc9fc5a89e7fc3d6d6f75007e6f9b8f4744[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 10:28:33 2025 +0100

    Delete old .tekton files

[33mcommit 5a97ccfe82240e1b52d0225c2d301356fc639027[m
Author: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
Date:   Tue Aug 12 09:21:54 2025 +0000

    Red Hat Konflux update todoapp-bundle
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit d37cda6de44a934bfd1b6fcfdd039fa71a5fbae5[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 10:00:54 2025 +0100

    Restructure Konflux components with explicit naming
    
    - Rename component files to be explicit about purpose:
      - konflux-todoapp-component.yaml → konflux-operator-component.yaml
      - konflux-todoappbundle-component.yaml → konflux-bundle-component.yaml
      - konflux-todoappcatalog-component.yaml → konflux-catalog-component.yaml
    
    - Standardise component names:
      - todoapp-operator (main operator)
      - todoapp-bundle (OLM bundle, not todoapp-operator-bundle)
      - todoapp-catalog (File-Based Catalog)
    
    - Move Dockerfiles to consistent root locations:
      - bundle/Dockerfile → bundle.Dockerfile
      - catalog.Dockerfile (already in root)
    
    - Update container image references to match new naming
    - Remove nested git repositories from index
    - Clean structure makes component purposes immediately clear

[33mcommit 98b7f83620d3b74975518c6cb7d39a7aeb9b223a[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Tue Aug 12 09:53:05 2025 +0100

    Move catalog Dockerfile to root directory
    
    Move catalog/Dockerfile to catalog.Dockerfile to separate build
    configuration from FBC catalog content. This prevents opm from
    parsing the Dockerfile as catalog configuration.

[33mcommit 5c42490f19eb695772deecfb3d7047929ff87153[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Tue Aug 12 09:38:51 2025 +0100

    Update docker.io/library/golang Docker tag to v1.24 (#12)
    
    Signed-off-by: red-hat-konflux <126015336+red-hat-konflux[bot]@users.noreply.github.com>
    Co-authored-by: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>

[33mcommit 67493692e7c6b01efaeea22aac0264d8902decf2[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 21:52:56 2025 +0100

    Update catalog Dockerfile to use modern opm base image
    
    Switch from manual opm installation to using the official
    quay.io/operator-framework/opm:v1.53.0 base image. This follows
    the same approach as network-observability-operator and provides
    better caching and performance for File-Based Catalogs.

[33mcommit a7ee808fc36efd330216ade5dc4f4a1c3e88ad1b[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Mon Aug 11 21:47:25 2025 +0100

    NFI (#11)
    
    Co-authored-by: Andrew McDermott <aim@frobware.com>

[33mcommit 0c8f8b9a70d30b7f17350cbbb9ab8bc55a84ede2[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Mon Aug 11 21:46:10 2025 +0100

    Red Hat Konflux purge todoapp-operator-bundle (#10)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit f187eab927acc6827e5cef049b51980a95d0388c[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Mon Aug 11 21:45:58 2025 +0100

    Red Hat Konflux purge todoapp-operator (#9)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit 88b018d7577e0e33d114354fdf6d578886767f26[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Mon Aug 11 21:45:43 2025 +0100

    Red Hat Konflux purge todoapp-catalog (#8)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit a3b5fde7b8cf283022a6f816426f71f3bff2c37a[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 21:16:27 2025 +0100

    Skip FBC validation checks for catalog builds

[33mcommit ee8af95bfe63f6e3a1ac55a8654635f7270389e6[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 21:10:41 2025 +0100

    Remove hermetic build annotation from catalog component

[33mcommit 4bd522919210e555197755c20fe3682edef57ee3[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 21:07:35 2025 +0100

    Set hermetic builds to false directly in catalog pipeline files

[33mcommit 3e6e447068161fbc3283e13f172e95bf3d316a90[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 21:05:07 2025 +0100

    Trigger catalog build to test hermetic build fix

[33mcommit 103fe5fc94583d3d9ecd1b4ab641009eaa867001[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 20:58:01 2025 +0100

    Disable hermetic builds for catalog component to allow opm binary download

[33mcommit cffc2a56869b2f63291110304f2ac38a6c61e4bf[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 20:54:07 2025 +0100

    Fix omp → opm typo in catalog Dockerfile
    
    - Corrected binary name from 'omp' to 'opm' in download and entrypoint
    - This was preventing the catalog from working properly
    - Now matches standard operator-registry binary naming

[33mcommit 3986c556c7ae3d0907efd1286dd49b97e01e8f2e[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 20:46:57 2025 +0100

    Upgrade catalog base image to UBI9
    
    - Use registry.access.redhat.com/ubi9/ubi:latest instead of ubi8
    - Maintains publicly accessible registry approach
    - Baby step toward modern base image while keeping proven pattern

[33mcommit 63b5d5026c434a051266f6c35735b634ab5e0426[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 20:38:17 2025 +0100

    Use konflux-test proven catalog approach
    
    - Use registry.access.redhat.com/ubi8/ubi:latest as base (publicly accessible)
    - Download opm binary from GitHub releases instead of using operator-registry base image
    - This avoids FBC validation base image restrictions
    - Same pattern used successfully by konflux-test-catalog component

[33mcommit a5681c6b9d35277af7118dedd04508b956787944[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 20:35:12 2025 +0100

    Revert "Use Red Hat brew registry for catalog base image"
    
    This reverts commit 9ae08e9d7324d14e7e097125533de9de24dd9794.

[33mcommit 9ae08e9d7324d14e7e097125533de9de24dd9794[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 20:33:59 2025 +0100

    Use Red Hat brew registry for catalog base image
    
    - Switch to brew.registry.redhat.io/rh-osbs/openshift-ose-operator-registry-rhel9:v4.17
    - This is the same base image used by network-observability-operator
    - Should pass Konflux FBC validation policies
    - Update opm command format to match brew image

[33mcommit d27d50afc91b79e86bad300f5e74fc464117f8f7[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 20:25:13 2025 +0100

    Fix catalog build by excluding Dockerfile from omp parsing
    
    - Only copy catalog/todoapp-operator directory, not entire catalog directory
    - Prevents Dockerfile from being parsed as catalog YAML by opm
    - Resolves JSON unmarshaling error during cache build
    - Tested locally with podman build - success

[33mcommit 02ec620f9c841cf356d3a2e16b9022b183986309[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 20:21:37 2025 +0100

    Use network-observability-operator image patterns
    
    Catalog:
    - Use quay.io/operator-framework/opm:v1.53.0 (pinned version)
    - Use standard FBC directory structure and labels
    - Pre-populate serve cache for better performance
    
    Operator:
    - Use registry.access.redhat.com/ubi9/ubi-minimal (publicly accessible)
    - Simplified user configuration

[33mcommit f6a48764d550f9403c4257be55d8629c96dcdd77[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 20:19:09 2025 +0100

    Use working catalog Dockerfile pattern from konflux-test
    
    - Use registry.access.redhat.com/ubi8/ubi:latest (publicly accessible)
    - Install opm binary directly instead of using operator-registry base image
    - Copy entire catalog directory structure
    - Based on successful konflux-test catalog build

[33mcommit 68d0896824aad3e688242782c42ca0bc2b4203ba[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 20:16:47 2025 +0100

    Try RHEL9 variant of operator-registry base image
    
    - registry.redhat.io/openshift4/ose-operator-registry:latest was not accessible
    - Switch to ose-operator-registry-rhel9:latest which should be available in Konflux

[33mcommit 2226bbe5ad4b8ed19879f41d90976075c4d4c752[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 19:28:01 2025 +0100

    Replace Docker Hub images with Red Hat registry equivalents
    
    - Use registry.redhat.io/ubi9/go-toolset:1.23 instead of docker.io/golang:1.23
    - Use registry.redhat.io/ubi9/ubi-micro instead of gcr.io/distroless/static
    - Configure non-root user for security compliance

[33mcommit 72ac087fe9a20de3afb6676ee5cae72836098c8b[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 19:26:04 2025 +0100

    Fix catalog base image to use approved Red Hat registry

[33mcommit f3ae329c37de2d24cec794d14ed80505fd45db47[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 19:22:39 2025 +0100

    Configure complete nudging chain for operator → bundle → catalog

[33mcommit cdb09c0a5761239b3fbb034da4231fee954eff93[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 19:18:06 2025 +0100

    Trigger build for operator nudge test

[33mcommit a739363bc92beee1e2c5ec5c83ed9e7d3941b14d[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Mon Aug 11 19:13:15 2025 +0100

    Red Hat Konflux update todoapp-catalog (#6)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit 862f783100d8e850edef9ce253265b47f7ed437b[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 19:02:10 2025 +0100

    Test catalog inclusion in snapshots after component recreation

[33mcommit 6694ed73ca32827fced6d8e5e96fb4f6fd6e4ba8[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 18:59:44 2025 +0100

    Revert "Switch catalog component to docker-build pipeline"
    
    This reverts commit fc2307f1ca6b7b72d5f341106b06df87a5f25738.

[33mcommit a35566dda674515149129c7fd98f4ad764032f78[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Mon Aug 11 18:58:12 2025 +0100

    Red Hat Konflux purge todoapp-catalog (#5)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit fc2307f1ca6b7b72d5f341106b06df87a5f25738[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 18:53:56 2025 +0100

    Switch catalog component to docker-build pipeline
    
    Change from fbc-builder to docker-build-oci-ta pipeline to resolve
    validation issues preventing catalog from being included in snapshots.

[33mcommit 1ed9abe08d9f0d3a4bf4da6ed2c9072b3d2b3830[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 16:15:31 2025 +0100

    Trigger build to test all 3 components

[33mcommit faa4d5c48d8820b4870ac28d4dcb51a70659988b[m
Author: red-hat-konflux[bot] <126015336+red-hat-konflux[bot]@users.noreply.github.com>
Date:   Mon Aug 11 16:15:03 2025 +0100

    Red Hat Konflux update todoapp-catalog (#3)
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
    Co-authored-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit a7530135c2e990169c1985354ce5273b60cf25e6[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 16:03:05 2025 +0100

    Fix FBC catalog format to match OLM validation requirements
    
    - Restore defaultChannel field to olm.package
    - Reorder channel fields to match working examples
    - Keep package field in olm.bundle for proper validation
    - Use multiline description format with pipe character
    
    These changes ensure the catalog passes opm validate locally.

[33mcommit e4f4b4c1302d7fabbed1f7ad588b533c56859ca4[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 14:59:24 2025 +0100

    Fix bundle image reference in catalog with actual SHA256 digest
    
    Replace placeholder SHA256 digest with the real digest from the built
    todoapp-operator-bundle image to allow FBC validation to succeed.

[33mcommit 9616a91fcf3e527a35bc55efcfd83d8a5a3ff4a3[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 13:36:15 2025 +0100

    Use public operator-framework image for catalog builds
    
    Switch from registry.redhat.io/openshift4/ose-operator-registry-rhel9:v4.16
    to quay.io/operator-framework/opm:latest to avoid authentication issues
    during Konflux builds. The public image provides the same FBC
    capabilities without requiring Red Hat registry credentials.

[33mcommit 027bba6403c15e4c0bb1910b7cfaaea1c2eff317[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 13:29:18 2025 +0100

    Fix FBC catalog for proper OLM validation
    
    - Use proper Red Hat FBC base image instead of scratch
    - Fix bundle image reference to use correct component name
    - Use valid SHA format instead of placeholder for validation

[33mcommit 8c3c78f115abdb1b8adeb089e40cd893f0ba3332[m
Merge: 559366d d6eaa57
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Mon Aug 11 13:27:40 2025 +0100

    Merge pull request #2 from frobware/konflux-todoapp-operator-bundle
    
    Red Hat Konflux update todoapp-operator-bundle

[33mcommit d6eaa57b4d54f99b538fdfc655be3762b6a98a9e[m[33m ([m[1;32mkonflux-todoapp-operator-bundle[m[33m)[m
Author: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
Date:   Mon Aug 11 11:24:42 2025 +0000

    Red Hat Konflux update todoapp-operator-bundle
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit 559366d6d650b41c48684e11fab5c6085ec871ff[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 13:13:50 2025 +0100

    Fix catalog Dockerfile paths for Konflux build context
    
    Catalog build was failing because COPY path was relative to catalog/ directory,
    but Konflux builds from repo root. Updated path to catalog/todoapp-operator/catalog.yaml
    to match the actual build context.

[33mcommit fe3508bd61532416cc450775bd8af9694b0c8b88[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 13:12:12 2025 +0100

    Fix bundle Dockerfile paths for Konflux build context
    
    Bundle build was failing because COPY paths were relative to bundle/ directory,
    but Konflux builds from repo root. Updated paths to bundle/manifests and
    bundle/metadata to match the actual build context.

[33mcommit 03ec714568e15c03baa42e889c789c5df19bde17[m
Merge: 673c994 99db69d
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Mon Aug 11 12:43:15 2025 +0100

    Merge pull request #1 from frobware/konflux-todoapp-operator
    
    Red Hat Konflux update todoapp-operator

[33mcommit 673c99440b6dd2909b509a3bde13e9b3b9be8397[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 12:20:15 2025 +0100

    Update Konflux components with proper naming and ImageRepositories
    
    - Rename components to follow operator conventions: todoapp-operator, todoapp-operator-bundle, todoapp-catalog
    - Add ImageRepository resources for each component with public visibility
    - Fix container image paths to match working konflux-test pattern
    - Components now properly configured for PAC pipeline generation

[33mcommit 99db69d3efba97d689477d495a1e2b9a51b8e086[m
Author: red-hat-konflux <konflux@no-reply.konflux-ci.dev>
Date:   Mon Aug 11 11:15:57 2025 +0000

    Red Hat Konflux update todoapp-operator
    
    Signed-off-by: red-hat-konflux <konflux@no-reply.konflux-ci.dev>

[33mcommit b19f011f94145f0bdd65798c3b2075d4ca95cc0b[m
Author: Andrew McDermott <aim@frobware.com>
Date:   Mon Aug 11 12:04:24 2025 +0100

    Initial commit: TodoApp operator with Konflux multi-component build
    
    - Complete Kubernetes operator built with Kubebuilder
    - TodoApp custom resource with image, replicas, port fields
    - Controller creates Deployment and Service resources
    - OLM bundle with ClusterServiceVersion
    - File-based catalog using modern YAML format
    - Konflux Application and Component definitions for 3-component build
    - Component nudging configuration for coordinated builds
    
    Ready for Konflux onboarding and multi-release management.

[33mcommit 2012d42cefd984773178bcc73f6668dce9a4ae5c[m
Author: Andrew McDermott <frobware@users.noreply.github.com>
Date:   Mon Aug 11 11:48:58 2025 +0100

    Initial commit
