# Yutyrannus NVIDIA — GNOME OS NVIDIA testbed image
# List available commands
[group('info')]
default:
    @just --list

# ── Configuration ─────────────────────────────────────────────────────
export image_name := env("BUILD_IMAGE_NAME", "yutyrannus-nvidia")
export image_tag := env("BUILD_IMAGE_TAG", "latest")

export gaming := env("BUILD_GAMING", "false")
export base_dir := env("BUILD_BASE_DIR", ".")
export filesystem := env("BUILD_FILESYSTEM", "btrfs")

export bst2_image := env("BST2_IMAGE", "registry.gitlab.com/freedesktop-sdk/infrastructure/freedesktop-sdk-docker-images/bst2")

export vm_ram := env("VM_RAM", "8192")
export vm_cpus := env("VM_CPUS", "4")

export OCI_IMAGE_CREATED := env("OCI_IMAGE_CREATED", "")
export OCI_IMAGE_REVISION := env("OCI_IMAGE_REVISION", "")
export OCI_IMAGE_VERSION := env("OCI_IMAGE_VERSION", "latest")

# ── BuildStream wrapper ──────────────────────────────────────────────
[group('dev')]
bst *ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "${HOME}/.cache/buildstream"
    DEFAULT_BST_FLAGS="-o x86_64_v3 false --no-interactive"
    if [ -n "${BST_FLAGS_OVERRIDE:-}" ]; then
        EFFECTIVE_BST_FLAGS="${BST_FLAGS_OVERRIDE}"
    else
        EFFECTIVE_BST_FLAGS="${BST_FLAGS:-}"
        if [[ ! " ${EFFECTIVE_BST_FLAGS} " =~ [[:space:]]-o[[:space:]]+x86_64_v3[[:space:]]+(true|false)([[:space:]]|$) ]]; then
            EFFECTIVE_BST_FLAGS="${DEFAULT_BST_FLAGS} ${EFFECTIVE_BST_FLAGS}"
        fi
        if [[ ! " ${EFFECTIVE_BST_FLAGS} " =~ [[:space:]]--no-interactive([[:space:]]|$) ]]; then
            EFFECTIVE_BST_FLAGS="${EFFECTIVE_BST_FLAGS} --no-interactive"
        fi
        if [[ ! " ${EFFECTIVE_BST_FLAGS} " =~ [[:space:]]-o[[:space:]]+gaming[[:space:]]+(true|false)([[:space:]]|$) ]]; then
            EFFECTIVE_BST_FLAGS="${EFFECTIVE_BST_FLAGS} -o gaming {{gaming}}"
        fi
    fi
    podman run --rm \
        --privileged \
        --device /dev/fuse \
        --network=host \
        ${BST_PODMAN_EXTRA_ARGS:-} \
        -v "{{justfile_directory()}}:/src:rw" \
        -v "${HOME}/.cache/buildstream:/root/.cache/buildstream:rw" \
        -w /src \
        "{{bst2_image}}" \
        bash -c 'bst --colors "$@"' -- ${EFFECTIVE_BST_FLAGS} {{ARGS}}

# ── Build ─────────────────────────────────────────────────────────────
[group('build')]
build:
    #!/usr/bin/env bash
    set -euo pipefail
    ELEMENT="oci/yutyrannus-nvidia.bst"
    echo "==> Building $ELEMENT with BuildStream (inside bst2 container)..."
    just bst build "$ELEMENT"
    just export

# ── Export ─────────────────────────────────────────────────────────────
[group('build')]
export:
    #!/usr/bin/env bash
    set -euo pipefail
    ELEMENT="oci/yutyrannus-nvidia.bst"
    FINAL_NAME="{{image_name}}"
    if [ "{{gaming}}" = "true" ]; then
        FINAL_NAME="${FINAL_NAME}-gaming"
    fi
    FINAL_TAG="{{image_tag}}"
    SUDO_CMD=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO_CMD="sudo"
    fi
    echo "==> Exporting OCI image ($ELEMENT → ${FINAL_NAME}:${FINAL_TAG})..."
    rm -rf .build-out
    just bst artifact checkout "$ELEMENT" --directory /src/.build-out
    echo "==> Loading and squashing OCI image..."
    IMAGE_ID=$($SUDO_CMD podman pull -q oci:.build-out)
    rm -rf .build-out
    LABEL_ARGS=""
    if [ -n "${OCI_IMAGE_CREATED}" ]; then
        LABEL_ARGS="${LABEL_ARGS} --label org.opencontainers.image.created=${OCI_IMAGE_CREATED}"
    fi
    if [ -n "${OCI_IMAGE_REVISION}" ]; then
        LABEL_ARGS="${LABEL_ARGS} --label org.opencontainers.image.revision=${OCI_IMAGE_REVISION}"
    fi
    if [ -n "${OCI_IMAGE_VERSION}" ]; then
        LABEL_ARGS="${LABEL_ARGS} --label org.opencontainers.image.version=${OCI_IMAGE_VERSION}"
    fi
    DATE_TAG="$(date -u +%Y%m%d)"
    printf 'FROM %s\nRUN OS_RELEASE_MTIME="$(stat -c %%y /usr/lib/os-release)" \\\n    && USR_LIB_MTIME="$(stat -c %%y /usr/lib)" \\\n    && sed -i "s/^VERSION_ID=.*/VERSION_ID=\\"%s\\"/" /usr/lib/os-release \\\n    && sed -i "s/^IMAGE_VERSION=.*/IMAGE_VERSION=\\"%s\\"/" /usr/lib/os-release \\\n    && touch -d "$OS_RELEASE_MTIME" /usr/lib/os-release \\\n    && touch -d "$USR_LIB_MTIME" /usr/lib\n' "$IMAGE_ID" "$DATE_TAG" "$DATE_TAG" \
        | $SUDO_CMD podman build --pull=never --security-opt label=type:unconfined_t --squash-all ${LABEL_ARGS} -t "${FINAL_NAME}:${FINAL_TAG}" -f - .
    $SUDO_CMD podman rmi "$IMAGE_ID" || true
    echo "==> Export complete. Image loaded as ${FINAL_NAME}:${FINAL_TAG}"
    $SUDO_CMD podman images | grep -E "{{image_name}}|REPOSITORY" || true

# ── Push ──────────────────────────────────────────────────────────────
[group('dev')]
push-local registry="localhost:5000":
    #!/usr/bin/env bash
    set -euo pipefail
    SUDO_CMD=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO_CMD="sudo"
    fi
    SOURCE_REF="{{image_name}}:{{image_tag}}"
    TARGET_REF="{{registry}}/{{image_name}}:{{image_tag}}"
    if ! $SUDO_CMD podman image exists "$SOURCE_REF"; then
        echo "ERROR: Image '$SOURCE_REF' not found in podman." >&2
        echo "Run 'just export' first." >&2
        exit 1
    fi
    trap '$SUDO_CMD podman rmi "$TARGET_REF" >/dev/null 2>&1 || true' EXIT
    echo "==> Tagging $SOURCE_REF as $TARGET_REF"
    $SUDO_CMD podman tag "$SOURCE_REF" "$TARGET_REF"
    echo "==> Pushing $TARGET_REF"
    $SUDO_CMD podman push "$TARGET_REF"

# ── Clean ─────────────────────────────────────────────────────────────
[group('build')]
clean:
    rm -f bootable.raw .ovmf-vars.fd
    rm -rf .build-out

# ── Containerfile build (lint helper only) ───────────────────────────
[group('build')]
build-containerfile $image_name=image_name:
    sudo podman build --security-opt label=type:unconfined_t --squash-all -t "${image_name}:latest" .

# ── bootc helper ─────────────────────────────────────────────────────
[group('dev')]
bootc *ARGS:
    sudo podman run \
        --rm --privileged --pid=host \
        -it \
        -v /var/lib/containers:/var/lib/containers \
        -v /dev:/dev \
        -v "{{base_dir}}:/data" \
        --security-opt label=type:unconfined_t \
        "{{image_name}}:{{image_tag}}" bootc {{ARGS}}

# ── Generate bootable disk image ─────────────────────────────────────
[group('test')]
generate-bootable-image $base_dir=base_dir $filesystem=filesystem:
    #!/usr/bin/env bash
    set -euo pipefail
    REF="{{image_name}}:{{image_tag}}"
    if ! sudo podman image exists "$REF"; then
        echo "ERROR: Image '$REF' not found in podman." >&2
        echo "Run 'just build' first to build and export the OCI image." >&2
        exit 1
    fi
    if [ ! -e "${base_dir}/bootable.raw" ] ; then
        echo "==> Creating 30G sparse disk image..."
        fallocate -l 30G "${base_dir}/bootable.raw"
    fi
    echo "==> Installing $REF to disk image via bootc..."
    BUILD_IMAGE_NAME="{{image_name}}" just bootc install to-disk \
        --via-loopback /data/bootable.raw \
        --filesystem "${filesystem}" \
        --wipe \
        --composefs-backend \
        --bootloader systemd \
        --karg systemd.firstboot=no \
        --karg splash \
        --karg quiet
    echo "==> Bootable disk image ready: ${base_dir}/bootable.raw"
    sync
    rm -f "${base_dir}/bootable.qcow2"

# ── Boot VM ──────────────────────────────────────────────────────────
[group('test')]
boot-vm $base_dir=base_dir:
    #!/usr/bin/env bash
    set -euo pipefail
    DISK=$(realpath "{{base_dir}}/bootable.raw")
    if [ ! -e "$DISK" ]; then
        echo "ERROR: ${DISK} not found. Run 'just generate-bootable-image' first." >&2
        exit 1
    fi
    if command -v qemu-system-x86_64 &>/dev/null; then
        echo "==> Using native qemu-system-x86_64..."
        OVMF_CODE=""
        for candidate in \
            /usr/share/edk2/ovmf/OVMF_CODE.fd \
            /usr/share/OVMF/OVMF_CODE.fd \
            /usr/share/OVMF/OVMF_CODE_4M.fd \
            /usr/share/edk2/x64/OVMF_CODE.4m.fd \
            /usr/share/qemu/OVMF_CODE.fd; do
            if [ -f "$candidate" ]; then
                OVMF_CODE="$candidate"
                break
            fi
        done
        if [ -z "$OVMF_CODE" ]; then
            echo "ERROR: OVMF firmware not found. Install edk2-ovmf (Fedora) or ovmf (Debian/Ubuntu)." >&2
            exit 1
        fi
        OVMF_VARS="{{base_dir}}/.ovmf-vars.fd"
        if [ ! -e "$OVMF_VARS" ]; then
            OVMF_VARS_SRC=""
            for candidate in \
                /usr/share/edk2/ovmf/OVMF_VARS.fd \
                /usr/share/OVMF/OVMF_VARS.fd \
                /usr/share/OVMF/OVMF_VARS_4M.fd \
                /usr/share/edk2/x64/OVMF_VARS.4m.fd \
                /usr/share/qemu/OVMF_VARS.fd; do
                if [ -f "$candidate" ]; then
                    OVMF_VARS_SRC="$candidate"
                    break
                fi
            done
            if [ -z "$OVMF_VARS_SRC" ]; then
                echo "ERROR: OVMF_VARS not found alongside OVMF_CODE." >&2
                exit 1
            fi
            cp "$OVMF_VARS_SRC" "$OVMF_VARS"
        fi
        echo "==> Booting ${DISK} in QEMU (UEFI, KVM)..."
        echo "    Firmware: ${OVMF_CODE}"
        echo "    RAM: {{vm_ram}}M, CPUs: {{vm_cpus}}"
        echo "    Serial debug shell on ttyS1 available via QEMU monitor"
        echo ""
        qemu-system-x86_64 \
            -enable-kvm \
            -m "{{vm_ram}}" \
            -cpu host \
            -smp "{{vm_cpus}}" \
            -drive file="${DISK}",format=raw,if=virtio \
            -drive if=pflash,format=raw,readonly=on,file="${OVMF_CODE}" \
            -drive if=pflash,format=raw,file="${OVMF_VARS}" \
            -device virtio-vga \
            -display gtk \
            -device virtio-keyboard \
            -device virtio-mouse \
            -device virtio-net-pci,netdev=net0 \
            -netdev user,id=net0,hostfwd=tcp:127.0.0.1:2222-:22 \
            -chardev stdio,id=char0,mux=on,signal=off \
            -serial chardev:char0 \
            -serial chardev:char0 \
            -mon chardev:char0
    else
        echo "==> qemu-system-x86_64 not found, falling back to docker.io/qemux/qemu-docker..."
        BOOT_MOUNT="/boot.img"
        if [ -e "{{base_dir}}/bootable.qcow2" ]; then
            DISK=$(realpath "{{base_dir}}/bootable.qcow2")
            BOOT_MOUNT="/boot.qcow2"
        fi
        port=8006
        while grep -q :${port} <<< $(ss -tunalp); do
            port=$(( port + 1 ))
        done
        echo "==> Web/VNC accessible at http://localhost:${port}"
        xdg-open "http://localhost:${port}" &>/dev/null || true
        podman run \
            --rm --privileged \
            --device /dev/kvm \
            --pull=always \
            --publish "127.0.0.1:${port}:8006" \
            --publish "127.0.0.1:2222:22" \
            --env "USER_PORTS=22" \
            --env "NETWORK=user" \
            --env "CPU_CORES={{vm_cpus}}" \
            --env "RAM_SIZE={{vm_ram}}" \
            --env "TPM=y" \
            --env "BOOT_MODE=${BOOT_MODE:-uefi}" \
            --env "ARGUMENTS=-snapshot" \
            --volume "${DISK}:${BOOT_MOUNT}" \
            ghcr.io/qemux/qemu:latest
    fi

# ── Convert to qcow2 ──────────────────────────────────────────────────
[group('test')]
convert-to-qcow2 $base_dir=base_dir:
    #!/usr/bin/env bash
    set -euo pipefail
    RAW="{{base_dir}}/bootable.raw"
    QCOW2="{{base_dir}}/bootable.qcow2"
    if [ ! -e "$RAW" ]; then
        echo "ERROR: ${RAW} not found. Run 'just generate-bootable-image' first." >&2
        exit 1
    fi
    echo "==> Converting ${RAW} to ${QCOW2}..."
    if command -v qemu-img &>/dev/null; then
        qemu-img convert -f raw -O qcow2 "$RAW" "$QCOW2"
    else
        echo "    Using containerized qemu-img..."
        podman run --rm \
            -v "{{base_dir}}:/data" \
            --entrypoint qemu-img \
            ghcr.io/qemux/qemu:latest \
            convert -f raw -O qcow2 "/data/bootable.raw" "/data/bootable.qcow2"
    fi
    echo "==> Conversion complete: ${QCOW2}"

# ── bcvk (fast VM testing) ───────────────────────────────────────────

_ensure-bcvk:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v bcvk &>/dev/null; then
        exit 0
    fi
    echo "bcvk not found. Attempting to install via cargo..."
    if command -v cargo &>/dev/null; then
        cargo install --locked --git https://github.com/bootc-dev/bcvk bcvk
    else
        echo "ERROR: bcvk is not installed and cargo is not available for auto-install." >&2
        echo "" >&2
        echo "Install bcvk manually:" >&2
        echo "  Cargo:       cargo install --locked --git https://github.com/bootc-dev/bcvk bcvk" >&2
        echo "  Fedora 42+:  sudo dnf install bcvk" >&2
        echo "" >&2
        echo "Also ensure qemu-kvm and virtiofsd are installed on the host." >&2
        exit 1
    fi

[group('test')]
boot-fast: _ensure-bcvk
    #!/usr/bin/env bash
    set -euo pipefail
    SUDO_CMD=""
    if [ "$(id -u)" -ne 0; then
        SUDO_CMD="sudo"
    fi
    if ! $SUDO_CMD podman image exists "{{image_name}}:{{image_tag}}"; then
        echo "ERROR: Image '{{image_name}}:{{image_tag}}' not found in podman." >&2
        echo "Run 'just build' first to build and export the OCI image." >&2
        exit 1
    fi
    echo "==> Booting {{image_name}}:{{image_tag}} in ephemeral VM (bcvk)..."
    echo "    RAM: {{vm_ram}}M, CPUs: {{vm_cpus}}"
    echo "    No disk image -- boots directly via virtiofs"
    echo ""
    $SUDO_CMD bcvk ephemeral run-ssh \
        --memory "{{vm_ram}}M" \
        --vcpus "{{vm_cpus}}" \
        "localhost/{{image_name}}:{{image_tag}}"

[group('test')]
debug-session: _ensure-bcvk
    #!/usr/bin/env bash
    set -euo pipefail
    VM_NAME="yutyrannus-debug-$$"
    SESSION_DIR="./debug-session"
    START_TS=$(date +%s)
    SUDO_MD=""
    if [ "$(id -u)" -ne 0; then
        SUDO_CMD="sudo"
    fi
    if ! $SUDO_CMD podman image exists "{{image_name}}:{{image_tag}}"; then
        echo "ERROR: Image '{{image_name}}:{{image_tag}}' not found in podman." >&2
        echo "Run 'just build' first to build and export the OCI image." >&2
        exit 1
    fi
    cleanup() {
        set +e
        END_TS=$(date +%s)
        DURATION=$((END_TS - START_TS))
        $SUDO_CMD podman logs "$VM_NAME" > "${SESSION_DIR}/serial.log" 2>/dev/null || true
        KERNEL="unknown"
        FAILED_DISPLAY="none"
        if $SUDO_CMD bcvk ephemeral ssh "$VM_NAME" -- true 2>/dev/null; then
            echo "==> Capturing systemd journal..."
            $SUDO_CMD bcvk ephemeral ssh "$VM_NAME" -- journalctl -b --no-pager > "${SESSION_DIR}/journal.log" 2>/dev/null || true
            KERNEL=$($SUDO_CMD bcvk ephemeral ssh "$VM_NAME" -- uname -r 2>/dev/null || echo "unknown")
            FAILED=$($SUDO_CMD bcvk ephemeral ssh "$VM_NAME" -- systemctl list-units --state=failed --no-legend --plain 2>/dev/null | awk '{print $1}' | head -10 | paste -sd ',' 2>/dev/null || true)
            if [ -n "$FAILED" ]; then FAILED_DISPLAY="$FAILED"; fi
        fi
        {
            echo "Debug session: {{image_name}}:{{image_tag}}"
            echo "Duration: ${DURATION}s"
            echo "Kernel: ${KERNEL}"
            echo "Failed units: ${FAILED_DISPLAY}"
            echo ""
            echo "Artifacts:"
            echo "  serial.log   — full serial console from boot"
            echo "  journal.log  — systemd journal from this boot"
            echo "  summary.txt  — this file"
            echo ""
            echo "Include these artifacts when filing an issue at:"
            echo "  https://github.com/robin/yutyrannus/issues/new?template=bug-report.yml"
        } > "${SESSION_DIR}/summary.txt"
        echo ""
        echo "==> Debug session artifacts in ${SESSION_DIR}/"
        if [[ -f "${SESSION_DIR}/serial.log" ]]; then
            echo "    serial.log   ($(du -sh "${SESSION_DIR}/serial.log" | cut -f1)) — full serial console from boot"
        fi
        if [[ -f "${SESSION_DIR}/journal.log" ]]; then
            echo "    journal.log  ($(du -sh "${SESSION_DIR}/journal.log" | cut -f1)) — systemd journal from this boot"
        fi
        if [[ -f "${SESSION_DIR}/summary.txt" ]]; then
            echo "    summary.txt  — session summary"
        fi
        echo ""
        echo "File an issue with the artifacts above:"
        echo "  https://github.com/robin/yutyrannus/issues/new?template=bug-report.yml"
        echo "==> Tearing down VM ${VM_NAME}..."
        $SUDO_CMD bcvk ephemeral rm -f "$VM_NAME" 2>/dev/null || true
    }
    trap cleanup EXIT
    mkdir -p "${SESSION_DIR}"
    echo "==> debug-session: booting {{image_name}}:{{image_tag}} with serial capture..."
    echo "    RAM: {{vm_ram}}M, CPUs: {{vm_cpus}}"
    echo "    Artifacts will be saved to ${SESSION_DIR}/"
    echo ""
    $SUDO_CMD bcvk ephemeral run -d --rm -K --console \
        --memory "{{vm_ram}}M" \
        --vcpus "{{vm_cpus}}" \
        --name "$VM_NAME" \
        "localhost/{{image_name}}:{{image_tag}}"
    echo "==> Waiting for VM to boot..."
    ELAPSED=0
    TIMEOUT=120
    while [ $ELAPSED -lt "$TIMEOUT" ]; do
        if $SUDO_CMD bcvk ephemeral ssh "$VM_NAME" -- true 2>/dev/null; then
            break
        fi
        sleep 5
        ELAPSED=$((ELAPSED + 5))
        printf '.' >&2
    done
    echo ""
    if [ $ELAPSED -ge "$TIMEOUT" ]; then
        echo "FAIL: SSH did not become available within ${TIMEOUT}s" >&2
        exit 1
    fi
    echo "==> VM ready after ~${ELAPSED}s. Starting interactive session."
    echo "    Reproduce your bug here. Exit the shell when done (Ctrl+D)."
    echo ""
    $SUDO_CMD bcvk ephemeral ssh "$VM_NAME"

[group('test')]
boot-test: _ensure-bcvk
    #!/usr/bin/env bash
    set -euo pipefail
    VM_NAME="yutyrannus-boot-test-$$"
    TIMEOUT="${BOOT_TEST_TIMEOUT:-120}"
    STATUS=1
    SUDO_CMD=""
    if [ "$(id -u)" -ne 0; then
        SUDO_CMD="sudo"
    fi
    if ! $SUDO_CMD podman image exists "{{image_name}}:{{image_tag}}"; then
        echo "ERROR: Image '{{image_name}}:{{image_tag}}' not found in podman." >&2
        echo "Run 'just build' first to build and export the OCI image." >&2
        exit 1
    fi
    cleanup() {
        echo "==> Tearing down VM ${VM_NAME}..."
        $SUDO_CMD bcvk ephemeral rm -f "$VM_NAME" 2>/dev/null || true
    }
    trap cleanup EXIT
    echo "==> boot-test: launching ephemeral VM (timeout: ${TIMEOUT}s)..."
    $SUDO_CMD bcvk ephemeral run -d --rm -K \
        --memory "{{vm_ram}}M" \
        --vcpus "{{vm_cpus}}" \
        --name "$VM_NAME" \
        "localhost/{{image_name}}:{{image_tag}}"
    echo "==> Waiting for SSH..."
    ELAPSED=0
    while [ $ELAPSED -lt "$TIMEOUT" ]; do
        if $SUDO_CMD bcvk ephemeral ssh "$VM_NAME" -- true 2>/dev/null; then
            break
        fi
        sleep 5
        ELAPSED=$((ELAPSED + 5))
    done
    if [ $ELAPSED -ge "$TIMEOUT" ]; then
        echo "FAIL: SSH did not become available within ${TIMEOUT}s" >&2
        exit 1
    fi
    echo "==> SSH up after ~${ELAPSED}s"
    echo "==> Checking critical services..."
    CHECKS=(
        "graphical.target:systemctl is-active graphical.target"
        "gdm:systemctl is-active gdm"
        "bootc:bootc status"
        "no-zram:test ! -e /sys/block/zram0"
    )
    PASS=0
    FAIL=0
    for check in "${CHECKS[@]}"; do
        NAME="${check%%:*}"
        CMD="${check#*:}"
        if $SUDO_CMD bcvk ephemeral ssh "$VM_NAME" -- $CMD &>/dev/null; then
            echo "  ✓ ${NAME}"
            PASS=$((PASS + 1))
        else
            echo "  ✗ ${NAME}" >&2
            FAIL=$((FAIL + 1))
        fi
    done
    echo ""
    if [ $FAIL -eq 0 ]; then
        echo "PASS: all ${PASS} checks passed"
        STATUS=0
    else
        echo "FAIL: ${FAIL} check(s) failed" >&2
    fi
    exit $STATUS

# Inspect the built bootc image.
[group('info')]
inspect: _ensure-bcvk
    #!/usr/bin/env bash
    set -euo pipefail
    SUDO_CMD=""
    if [ "$(id -u)" -ne 0; then
        SUDO_CMD="sudo"
    fi
    $SUDO_CMD bcvk images list

# ── Lint ─────────────────────────────────────────────────────────────
[group('test')]
lint:
    #!/usr/bin/env bash
    set -euo pipefail
    SUDO_CMD=""
    if [ "$(id -u)" -ne 0; then
        SUDO_CMD="sudo"
    fi
    echo "==> Linting {{image_name}}:{{image_tag}} with bootc container lint..."
    $SUDO_CMD podman run --rm --privileged --pull=never \
        "{{image_name}}:{{image_tag}}" \
        bootc container lint

# ── Swap audit ───────────────────────────────────────────────────────
[group('test')]
swap-audit:
    #!/usr/bin/env bash
    set -euo pipefail
    SUDO_CMD=""
    if [ "$(id -u)" -ne 0; then
        SUDO_CMD="sudo"
    fi
    echo "==> Auditing swap/zram configuration in {{image_name}}:{{image_tag}}..."
    $SUDO_CMD podman run --rm --pull=never \
        "{{image_name}}:{{image_tag}}" \
        bash -c '
        set -uo pipefail
        STATUS=0
        fail() { echo "FAIL: $1" >&2; STATUS=1; }
        if grep -q "^\[zram" /usr/lib/systemd/zram-generator.conf 2>/dev/null; then
            fail "/usr/lib/systemd/zram-generator.conf still defines a zram device"
        fi
        if compgen -G "/etc/systemd/zram-generator.conf*" > /dev/null; then
            fail "unexpected zram-generator config under /etc"
        fi
        KARGS=/usr/lib/bootc/kargs.d/20-zswap.toml
        if [ ! -f "$KARGS" ]; then
            fail "$KARGS missing"
        else
            grep -q "zswap.enabled=1" "$KARGS" || fail "zswap.enabled=1 karg missing"
            grep -q "zpool" "$KARGS" && fail "dead zswap.zpool karg present"
        fi
        [ -f /usr/lib/systemd/system/var-swap-swapfile.swap ] \
            || fail "var-swap-swapfile.swap unit missing"
        [ -L /usr/lib/systemd/system/swap.target.wants/var-swap-swapfile.swap ] \
            || fail "swap.target.wants/var-swap-swapfile.swap symlink missing"
        [ -x /usr/libexec/yutyrannus-swapfile-init ] \
            || fail "/usr/libexec/yutyrannus-swapfile-init missing or not executable"
        /usr/libexec/yutyrannus-swapfile-init \
            || fail "yutyrannus-swapfile-init exited non-zero"
        [ "$STATUS" -eq 0 ] && echo "PASS: swap/zram configuration OK"
        exit "$STATUS"
        '

# ── Avatar audit ─────────────────────────────────────────────────────
[group('test')]
avatar-audit:
    #!/usr/bin/env bash
    set -euo pipefail
    SUDO_CMD=""
    if [ "$(id -u)" -ne 0; then
        SUDO_CMD="sudo"
    fi
    echo "==> Auditing user-avatar configuration in {{image_name}}:{{image_tag}}..."
    $SUDO_CMD podman run --rm --pull=never \
        "{{image_name}}:{{image_tag}}" \
        bash -c '
        set -uo pipefail
        STATUS=0
        fail() { echo "FAIL: $1" >&2; STATUS=1; }
        Q=$(printf "\047")
        KEYFILE=/etc/dconf/db/distro.d/07-yutyrannus-avatar-directories
        DB=/etc/dconf/db/distro
        compgen -G "/usr/share/pixmaps/faces/bluefin/*.jpg" > /dev/null \
            || fail "no avatar art under /usr/share/pixmaps/faces/bluefin"
        grep -qx "system-db:distro" /etc/dconf/profile/user 2>/dev/null \
            || fail "/etc/dconf/profile/user does not read system-db:distro"
        if [ ! -f "$KEYFILE" ]; then
            fail "$KEYFILE missing"
        elif [ ! -f "$DB" ]; then
            fail "compiled dconf db $DB missing -- did dconf update run?"
        else
            VALUE=$(sed -n "s/^avatar-directories=//p" "$KEYFILE")
            if [ -z "$VALUE" ]; then
                fail "avatar-directories key missing from $KEYFILE"
            else
                DIRS=$(printf "%s" "$VALUE" | tr -d "[]${Q} " | tr "," "\n" | grep -v "^$")
                if [ -z "$DIRS" ]; then
                    fail "avatar-directories is empty -- the picker would show nothing"
                else
                    while read -r dir; do
                        [ -d "$dir" ] \
                            || { fail "avatar-directories lists $dir, which is not in the image"; continue; }
                        compgen -G "${dir}/*.jpg" > /dev/null \
                            || fail "$dir contains no .jpg faces"
                        grep -qaF "$dir" "$DB" \
                            || fail "$dir absent from compiled $DB -- override did not reach the db"
                    done <<< "$DIRS"
                fi
            fi
        fi
        [ "$STATUS" -eq 0 ] && echo "PASS: user-avatar configuration OK"
        exit "$STATUS"
        '
