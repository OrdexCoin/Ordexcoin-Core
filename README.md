# OrdexCoin Core v25.0.0

Bitcoin Core v25.0 fork by the OrdexNetwork project.

## Build

Requires Docker. The repository checkout is an incomplete rename (bitcoin* → ordexcoin*).
The build applies Bitcoin Core v25.0 as a base overlay, creates missing symlinks,
and patches identifiers to match the fork.

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

Binaries: `ordexcoind.exe`, `ordexcoin-cli.exe`, `ordexcoin-tx.exe`, `ordexcoin-wallet.exe`, `ordexcoin-util.exe`, `ordexcoin-qt.exe`

### Notes

- First build downloads and builds all dependencies from source (Boost, Qt 5.15, BDB 4.8, etc.).
  Allow 1-2 hours for Windows, 30-60 minutes for Linux.
- Subsequent builds cache unchanged layers.
- Individual binaries land in `build/linux/` or `build/windows/` respectively.
