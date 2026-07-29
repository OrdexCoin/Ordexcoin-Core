<p align="center">
  <img src="icon.png" alt="OrdexCoin Logo" width="256">
</p>

# OrdexCoin Core vASSERT version

OrdexCoin with vASERT difficulty adjustment feature.

This repository contains the Docker-based build system and the source overlay (`Ordexcoin-Core-vASERT-4790.zip`) that applies branding and configuration changes on top of Bitcoin Core v25.0.

## Build

Requires Docker. No other dependencies needed.

### Linux

```sh
./build-docker-linux.sh
```

Output: `build/ordexcoin-v25.0.0-linux-x86_64.tar.gz`

Binaries: `ordexcoind`, `ordexcoin-cli`, `ordexcoin-tx`, `ordexcoin-wallet`, `ordexcoin-util`, `ordexcoin-qt`

### Windows (cross-compile)

```sh
./build-docker-windows.sh
```

Output: `build/ordexcoin-v25.0.0-windows-x86_64.zip`

Binaries: `ordexcoind.exe`, `ordexcoin-cli.exe`, `ordexcoin-tx.exe`, `ordexcoin-wallet.exe`, `ordexcoin-util.exe`, `ordexcoin-qt.exe`, `libordexcoinconsensus-0.dll`

### Notes

- First build downloads and builds all dependencies from source (Boost, Qt 5.15, BDB 4.8, etc.).
  Allow 1-2 hours for Windows, 30-60 minutes for Linux. Subsequent builds cache unchanged layers.

## Patches Applied

All changes are applied by the Dockerfiles (`Dockerfile.linux`, `Dockerfile.windows`) on top of Bitcoin Core v25.0 baseline.

### 1. Backslash path normalization (`extract-zip.py`)

**Root cause of initial build failure.** The source overlay zip was created on Windows and uses backslash path separators (`\`). Python's `zipfile.extractall()` on Linux creates directories literally named `build-aux\m4\` instead of `build-aux/m4/`. This causes:

- `configure.ac` calls `ORDEXCOIN_QT_INIT` and `ORDEXCOIN_QT_CONFIGURE`
- These macros are defined in `ordexcoin_qt.m4` inside the zip
- But the file ends up at `build-aux\m4\ordexcoin_qt.m4` (with backslash dir name)
- `aclocal` scans `build-aux/m4/` (forward slash) and finds only the old `bitcoin_qt.m4`
- `ORDEXCOIN_QT_INIT` is never defined → `PKG_CHECK_MODULES` cascade failure

**Fix:** Replaced `z.extractall()` with a custom Python helper that normalizes `\` → `/` during extraction:

```python
for name in z.namelist():
    norm = name.replace('\\', '/')
    dst = os.path.join(outdir, norm)
    if norm.endswith('/'):
        os.makedirs(dst, exist_ok=True)
    else:
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        data = z.read(name)
        with open(dst, 'wb') as f:
            f.write(data)
```

### 2. Config filename rename

`util/system.cpp` and `util/system.h` contain the constant `BITCOIN_CONF_FILENAME` which must produce `ordexcoin.conf`:

```sed
s/BITCOIN_CONF_FILENAME/ORDEXCOIN_CONF_FILENAME/g
s/\"bitcoin\.conf\"/\"ordexcoin\.conf\"/g
```

### 3. Datadir path

The default data directory is set via string literals in `util/system.cpp`. The bare-string patterns `"/.bitcoin"` and `".bitcoin"` are replaced:

```sed
s|\"/\\.bitcoin\"|\"/\\.ordexcoin\"|g
s|\"\\.bitcoin\"|\"\\.ordexcoin\"|g
```

### 4. Branding / window titlebars

GUI window title bars, splash screen, and about dialog use the application name string:

```sed
s/\"Bitcoin Core\"/\"OrdexCoin Core\"/g
s/\"Bitcoin\"/\"Ordexcoin\"/g
```

Applied to Qt source files, translation files.

### 5. Symbol and identifier renames

Source-level identifiers to match the fork namespace:

- `BitcoinUnits` → `OrdexCoinUnits`
- `BitcoinAmountField` → `OrdexCoinAmountField`
- `BTC` → `OXC` (ticker symbol)
- `BITCOIN_URI_BEGIN` → `ORDEXCOIN_URI_BEGIN`
- `bitcoin-util` → `ordexcoin-util` (in help text)
- `bitcoin-wallet` → `ordexcoin-wallet` (in help text)

### 6. Binary name in error messages

User-facing error messages referencing the `bitcoind` binary name:

```sed
s/\bbitcoind\b/ordexcoind/g
```

### 7. Symlinks for renamed source files

The zip overlay renames many files (e.g., `bitcoin.cpp` → `ordexcoin.cpp`) but does not create symlinks for files that other build targets expect. Created explicitly:

```sh
ln -sf ordexcoin.cpp src/bitcoin.cpp
# and similar for headers, Qt files, locale .ts files
```

### 8. Locale translation symlinks

Translation `.ts` files were renamed to `ordexcoin_*.ts` but Qt's `lupdate`/`lrelease` searches for `bitcoin_*.ts`:

```sh
for f in src/qt/locale/ordexcoin_*.ts; do
    base=$(basename "$f" | sed 's/ordexcoin/bitcoin/')
    [ ! -e "src/qt/locale/$base" ] && ln -sf "$(basename "$f")" "src/qt/locale/$base"
done
```

### 9. Signed message magic string

The magic string used for signed message verification was renamed from `Bitcoin Signed Message:\n` to `Ordexcoin Signed Message:\n` to prevent cross-chain signature reuse.

### 10. Makefile.qttest.include ENABLE_TESTS wrapper

The zip file shipped a broken `Makefile.qttest.include` missing the `ENABLE_TESTS` conditional guard. Wrapped with:

```makefile
if ENABLE_TESTS
... content ...
endif
```

### 11. Permission fixes for build scripts

The zip file lacks execute permissions on several scripts. Set explicitly:

```sh
chmod +x share/genbuild.sh
chmod +x depends/config.guess depends/config.sub depends/gen_id
```

### 12. `"bitcoin-node"` and RPC example references

Help text referencing `bitcoin-node` and `bitcoin-cli` in usage examples were updated to `ordexcoin-node` and `ordexcoin-cli`.

## Verification

Both Linux and Windows binaries have been verified clean of user-facing branding residue:

- `strings ordexcoind | grep "\.bitcoin"` — only the legitimate BIP URL `en.bitcoin.it` remains
- `strings ordexcoind | grep "\bBITCOIND\b"` — no matches
- `strings ordexcoind | grep "bitcoin\.conf"` — no matches

The only remaining `bitcoin` strings in the binary are legitimate protocol references (addresses, transactions, BIP specification URLs, and copyright attributions), which correctly describe the underlying Bitcoin protocol that OrdexCoin implements.

## Attribution

This software is based on Bitcoin Core v25.0. Original copyright by The Bitcoin Core developers. Modifications by OrdexNetwork developers. 

## Support continous development

Support on-going development and infrastructure costs.

- EVM: 0x6e8e3c2b31424266e7cff59e910df1587c317427
- BTC: bc1qzzvcguvqjc6qhwe2y5vy38w2zke7hksukjhm68
- LTC: MPfm5QLKH1r9XxgWmH75Gyps4LDfX5c53L
- SOL: GGEaCMpnyM8tB5BU4RMuLm6tgMr3q9FgMHodxDxxAGby
- OXC: oxc1qcjav0mpjjvufc2zwfddnmep0janwv0czwk657e
