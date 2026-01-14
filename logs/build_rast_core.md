info: downloading installer
info: profile set to 'default'
info: default host triple is aarch64-apple-darwin
info: syncing channel updates for 'stable-aarch64-apple-darwin'
info: latest update on 2025-12-11, rust version 1.92.0 (ded5c06cf 2025-12-08)
info: downloading component 'cargo'
info: downloading component 'clippy'
info: downloading component 'rust-docs'
info: downloading component 'rust-std'
info: downloading component 'rustc'
info: downloading component 'rustfmt'
info: installing component 'cargo'
info: installing component 'clippy'
info: installing component 'rust-docs'
info: installing component 'rust-std'
info: installing component 'rustc'
info: installing component 'rustfmt'
info: default toolchain set to 'stable-aarch64-apple-darwin'

  stable-aarch64-apple-darwin installed - rustc 1.92.0 (ded5c06cf 2025-12-08)


Rust is installed now. Great!

To get started you may need to restart your current shell.
This would reload your PATH environment variable to include
Cargo's bin directory ($HOME/.cargo/bin).

To configure your current shell, you need to source
the corresponding env file under $HOME/.cargo.

This is usually done by running one of the following (note the leading DOT):
. "$HOME/.cargo/env"            # For sh/bash/zsh/ash/dash/pdksh
source "$HOME/.cargo/env.fish"  # For fish
source $"($nu.home-path)/.cargo/env.nu"  # For nushell
info: downloading component 'rust-std' for 'aarch64-apple-ios'
info: installing component 'rust-std' for 'aarch64-apple-ios'
    Updating crates.io index
 Downloading crates ...
  Downloaded aead v0.5.2
  Downloaded inout v0.1.4
  Downloaded cpufeatures v0.2.17
  Downloaded unicode-ident v1.0.22
  Downloaded getrandom v0.2.16
  Downloaded sha2 v0.10.9
  Downloaded zeroize_derive v1.4.3
  Downloaded version_check v0.9.5
  Downloaded serde_derive v1.0.228
  Downloaded thiserror v1.0.69
  Downloaded x25519-dalek v2.0.1
  Downloaded chacha20poly1305 v0.10.1
  Downloaded serde v1.0.228
  Downloaded hkdf v0.12.4
  Downloaded base64 v0.22.1
  Downloaded serde_core v1.0.228
  Downloaded proc-macro2 v1.0.105
  Downloaded poly1305 v0.8.0
  Downloaded hmac v0.12.1
  Downloaded chacha20 v0.9.1
  Downloaded thiserror-impl v1.0.69
  Downloaded semver v1.0.27
  Downloaded rand_core v0.6.4
  Downloaded syn v2.0.114
  Downloaded curve25519-dalek v4.1.3
  Downloaded quote v1.0.43
  Downloaded opaque-debug v0.3.1
  Downloaded generic-array v0.14.7
  Downloaded digest v0.10.7
  Downloaded crypto-common v0.1.7
  Downloaded cfg-if v1.0.4
  Downloaded zeroize v1.8.2
  Downloaded universal-hash v0.5.1
  Downloaded typenum v1.19.0
  Downloaded subtle v2.6.1
  Downloaded rustc_version v0.4.1
  Downloaded block-buffer v0.10.4
  Downloaded cipher v0.4.4
  Downloaded libc v0.2.180
   Compiling libc v0.2.180
   Compiling typenum v1.19.0
   Compiling version_check v0.9.5
   Compiling cfg-if v1.0.4
   Compiling proc-macro2 v1.0.105
   Compiling quote v1.0.43
   Compiling unicode-ident v1.0.22
   Compiling subtle v2.6.1
   Compiling semver v1.0.27
   Compiling serde_core v1.0.228
   Compiling thiserror v1.0.69
   Compiling generic-array v0.14.7
   Compiling rustc_version v0.4.1
   Compiling serde v1.0.228
   Compiling opaque-debug v0.3.1
   Compiling base64 v0.22.1
   Compiling curve25519-dalek v4.1.3
   Compiling getrandom v0.2.16
   Compiling cpufeatures v0.2.17
   Compiling rand_core v0.6.4
   Compiling syn v2.0.114
   Compiling crypto-common v0.1.7
   Compiling block-buffer v0.10.4
   Compiling inout v0.1.4
   Compiling universal-hash v0.5.1
   Compiling aead v0.5.2
   Compiling digest v0.10.7
   Compiling poly1305 v0.8.0
   Compiling hmac v0.12.1
   Compiling sha2 v0.10.9
   Compiling hkdf v0.12.4
   Compiling zeroize_derive v1.4.3
   Compiling serde_derive v1.0.228
   Compiling thiserror-impl v1.0.69
   Compiling zeroize v1.8.2
   Compiling cipher v0.4.4
   Compiling chacha20 v0.9.1
   Compiling chacha20poly1305 v0.10.1
   Compiling x25519-dalek v2.0.1
   Compiling helloworld_core v0.0.1 (/Users/builder/clone)
warning: unused import: `x25519_dalek::PublicKey`
 --> src/ffi.rs:6:5
  |
6 | use x25519_dalek::PublicKey;
  |     ^^^^^^^^^^^^^^^^^^^^^^^
  |
  = note: `#[warn(unused_imports)]` (part of `#[warn(unused)]`) on by default

warning: use of deprecated associated function `x25519_dalek::StaticSecret::new`: Renamed to `random_from_rng`. This will be removed in 2.1.0
  --> src/crypto/key_manager.rs:17:37
   |
17 |         let private = StaticSecret::new(OsRng);
   |                                     ^^^
   |
   = note: `#[warn(deprecated)]` on by default

warning: `helloworld_core` (lib) generated 2 warnings (run `cargo fix --lib -p helloworld_core` to apply 1 suggestion)
    Finished `release` profile [optimized] target(s) in 6.02s