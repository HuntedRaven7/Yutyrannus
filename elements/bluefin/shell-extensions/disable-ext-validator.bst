kind: manual

build-depends:
- core/sandbox-tools.bst

depends:
  - gnome-build-meta.bst:sdk/glib.bst
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ""

# Keep the established desktop plus extensions enabled. Personal integrations
# remain installed with their backends but are opt-in. Never rewrite existing
# users' extension selections.
config:
  install-commands:
    - mkdir -p "%{install-root}%{datadir}/glib-2.0/schemas/"
    - |
      cat <<EOF > "%{install-root}%{datadir}/glib-2.0/schemas/zz3-bluefin-unsupported-stuff.gschema.override"
      [org.gnome.shell]
      disable-extension-version-validation=true
      enabled-extensions=['caffeine@patapon.info', 'appindicatorsupport@rgcjonas.gmail.com', 'bazaar-integration@kolunmi.github.io', 'blur-my-shell@aunetx', 'dash-to-dock@micxgx.gmail.com', 'gradia-integration@alexandervanhee.github.io', 'gsconnect@andyholmes.github.io', 'custom-command-list@storageb.github.com']

      [org.gnome.shell.extensions.BudsLink-Companion]
      level-indicator-color=0
      EOF

    - "%{install-extra}"
