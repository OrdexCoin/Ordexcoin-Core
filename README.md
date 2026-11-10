<p align="center">
  <img src="icon.png" alt="OrdexCoin Core" width="220">
</p>

<h1 align="center">OrdexCoin Core</h1>

<p align="center">
  <strong>The reference node and wallet implementation for the OrdexCoin Layer-1 blockchain network.</strong>
</p>

<p align="center">
  <a href="https://github.com/OrdexCoin/Ordexcoin-Core/releases/latest"><img src="https://img.shields.io/github/v/release/OrdexCoin/Ordexcoin-Core?color=007ec6&label=Release" alt="Latest Release"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://github.com/OrdexCoin/Ordexcoin-Core"><img src="https://img.shields.io/badge/Consensus-SHA256d%20%7C%20ASERT-green.svg" alt="Consensus: SHA256d | ASERT"></a>
  <a href="https://github.com/OrdexCoin/Ordexcoin-Core"><img src="https://img.shields.io/badge/Base-Bitcoin%20Core%20v31-orange.svg" alt="Base: Bitcoin Core v31"></a>
  <a href="https://discord.gg/RaN5kYmHya"><img src="https://img.shields.io/badge/Discord-Community%20Chat-5865F2?logo=discord&logoColor=white" alt="Discord Community"></a>
</p>

---

## Overview

**OrdexCoin (OXC)** is a decentralized, peer-to-peer digital currency and store-of-value network built on standard Proof-of-Work (PoW) consensus.

With the release of **OrdexCoin Core v31.0.1**, a new engineering team has stepped in to actively drive, modernize, and scale the project. The codebase has been rebased natively onto **Bitcoin Core v31**, replacing legacy wrappers with a modern CMake build system, descriptor wallets, native Taproot and SegWit support, and an advanced **ASERT per-block difficulty adjustment algorithm**.

> [!IMPORTANT]
> **Mandatory Consensus Upgrade:** Starting at block **5,570**, OrdexCoin activates per-block ASERT difficulty retargeting with a 2-hour half-life to permanently prevent chain stalls. All miners, node operators, pools, and wallet users must run version **31.0.1 or higher**. Legacy nodes will stop following consensus at block 5,569.

---

## Network Specifications

| Specification | Parameter / Value |
|---|---|
| **Ticker Symbol** | `OXC` |
| **Consensus Algorithm** | Proof-of-Work (PoW) — SHA256d (ASIC & GPU compatible) |
| **Block Interval** | 10 minutes (600 seconds) |
| **Difficulty Adjustment** | ASERT (`aserti3-2d`, calculated per block with 2-hour half-life) |
| **Hard Fork Anchor Height** | Block `5,570` (Anchor difficulty ~250,000 / `0x1a431b9b`) |
| **Native Bech32 Prefix** | `oxc` (e.g. `oxc1q...`) |
| **Testnet Bech32 Prefix** | `toxc` |
| **Default P2P Port** | `25174` (Mainnet) / `35174` (Testnet) |
| **Default RPC Port** | `29347` (Mainnet) / `18332` (Testnet) |
| **Build System** | Native CMake with cross-compilation support |

---

## Official Binary Downloads (v31.0.1)

Pre-compiled, reproducible static binaries are available for major operating systems:

| Platform | Target Architecture | Type | Package Link |
|---|---|---|---|
| **Windows 10 / 11** | x86_64 | Installer | [`ordexcoin-31.0.1-win64-setup.exe`](https://github.com/OrdexCoin/Ordexcoin-Core/releases/download/v31.0.1/ordexcoin-31.0.1-win64-setup.exe) |
| **Windows Portable** | x86_64 | Standalone ZIP | [`ordexcoin-31.0.1-win64.zip`](https://github.com/OrdexCoin/Ordexcoin-Core/releases/download/v31.0.1/ordexcoin-31.0.1-win64.zip) |
| **Linux (Modern distros)** | x86_64 | Tarball | [`ordexcoin-31.0.1-linux-x86_64.tar.gz`](https://github.com/OrdexCoin/Ordexcoin-Core/releases/download/v31.0.1/ordexcoin-31.0.1-linux-x86_64.tar.gz) |
| **Raspberry Pi / ARM64** | aarch64 (64-bit) | Tarball | [`ordexcoin-31.0.1-raspberrypi-arm64.tar.gz`](https://github.com/OrdexCoin/Ordexcoin-Core/releases/download/v31.0.1/ordexcoin-31.0.1-raspberrypi-arm64.tar.gz) |
| **Checksums** | SHA-256 | Verification | [`SHA256SUMS.txt`](https://github.com/OrdexCoin/Ordexcoin-Core/releases/download/v31.0.1/SHA256SUMS.txt) |

Every release bundle contains the complete toolset:
- `ordexcoin-qt` — Desktop GUI wallet and node monitor.
- `ordexcoind` — Headless full-node daemon for servers and mining rigs.
- `ordexcoin-cli` — Command-line RPC client interface.
- `ordexcoin-wallet` — Offline wallet creation and inspection utility.
- `ordexcoin-tx` / `ordexcoin-util` — Transaction assembly and cryptographic utilities.

---

## Quick Start Guide

### 1. Running on Windows
1. Download and run `ordexcoin-31.0.1-win64-setup.exe` (or unzip `ordexcoin-31.0.1-win64.zip`).
2. Launch `ordexcoin-qt.exe`.
3. Allow the initial blockchain synchronization to complete.

### 2. Running on Linux / Raspberry Pi
```bash
# Extract the binary release
tar -xzf ordexcoin-31.0.1-linux-x86_64.tar.gz
cd ordexcoin-31.0.1/bin

# Start the full node daemon
./ordexcoind -daemon

# Check node synchronization status
./ordexcoin-cli getblockchaininfo
```

### 3. Recommended Node Configuration (`ordexcoin.conf`)

Place or edit your configuration file in the OrdexCoin data directory:
- **Windows:** `%APPDATA%\OrdexCoin\ordexcoin.conf`
- **Linux / macOS:** `~/.ordexcoin/ordexcoin.conf`

```ini
# Network settings
server=1
listen=1
daemon=1

# P2P connection to active seed nodes
addnode=stratum.shears.co.uk:25174
addnode=185.250.241.209:25174

# Port binding configuration (prevents Tor/local port clash in v31)
bind=0.0.0.0:25174

# RPC Configuration
rpcuser=ordexrpc
rpcpassword=ChangeThisToAStrongRandomSecretPassword123!
rpcport=29347
rpcallowip=127.0.0.1
```

> [!TIP]
> **Port clash resolution:** Bitcoin Core v31 opens an internal Tor listening port on `P2P port + 1`. If your `rpcport` was previously configured as `25174` or `25175`, ensure `rpcport` is set to `29347` (or bind explicitly with `bind=0.0.0.0:25174`).

---

## Upgrading from Legacy Versions (v25.x)

1. **Create a Backup First:** In your existing wallet, navigate to `File` → `Backup Wallet` and store your wallet file securely.
2. Stop the legacy node (`ordexcoin-cli stop`) or close the old wallet.
3. Replace the binaries with **v31.0.1**. Your existing data directory and descriptors will be loaded automatically.
4. If migrating from very old legacy BerkeleyDB wallets, use `File` → `Migrate Wallet` inside the v31 GUI or invoke the `migratewallet` RPC.

---

## Building from Source

OrdexCoin Core v31 uses **CMake** for clean, fast, and cross-platform compilation.

### Prerequisites (Ubuntu / Debian)

```bash
sudo apt update && sudo apt install -y \
    build-essential \
    cmake \
    pkg-config \
    libevent-dev \
    libboost-dev \
    libsqlite3-dev \
    qtbase5-dev \
    qttools5-dev-tools \
    libminiupnpc-dev \
    libnatpmp-dev \
    libzmq3-dev
```

### Compile with CMake

```bash
# Clone the official repository
git clone https://github.com/OrdexCoin/Ordexcoin-Core.git
cd Ordexcoin-Core

# Configure the build tree
cmake -B build -DCMAKE_BUILD_TYPE=Release

# Build binaries using all available CPU threads
cmake --build build -j$(nproc)

# (Optional) Install system-wide
sudo cmake --install build
```

### Running Automated Tests

```bash
# Run unit test suite
ctest --test-dir build --output-on-failure

# Run Python-based functional regression tests
python3 test/functional/test_runner.py
```

For advanced instructions (MSVC, macOS, MinGW cross-compilation, depends system), consult the documentation in [`doc/`](doc/).

---

## Mining OrdexCoin

OrdexCoin uses the standard **SHA256d** hashing algorithm. It can be mined using ASIC hardware, GPUs, or CPU miners pointing to compatible Stratum mining pools or running solo against a full node.

### Solo Mining Setup
Ensure `server=1`, `rpcuser`, and `rpcpassword` are set in `ordexcoin.conf`. Your miner can fetch work via the standard Bitcoin-compatible `getblocktemplate` RPC interface on port `29347`.

### Pool Mining
Connect your SHA256 mining hardware to active community pools:
- **Shears Mining Pool:** `stratum+tcp://stratum.shears.co.uk:3333`
- Additional community pools and solo proxy instructions can be found on our [Discord](https://discord.gg/RaN5kYmHya).

---

## Developer Onboarding & Contributing

A renewed core team is actively maintaining and expanding OrdexCoin Core. We welcome developers, cryptographers, node operators, and community builders to collaborate with us.

- **Coding Standard:** Clean C++20, explicit error propagation, no unhandled exceptions, and strict types.
- **Workflow:** Fork the repository, create a descriptive feature branch (`feat/...`, `fix/...`), add unit or functional tests, and submit a Pull Request.
- **Review Culture:** All pull requests are reviewed for consensus safety, memory security, and network compatibility.
- For in-depth guidelines, see [`CONTRIBUTING.md`](CONTRIBUTING.md) and [`doc/developer-notes.md`](doc/developer-notes.md).

---

## Community & Resources

- **Official Repository:** [https://github.com/OrdexCoin/Ordexcoin-Core](https://github.com/OrdexCoin/Ordexcoin-Core)
- **Discord Server:** [https://discord.gg/RaN5kYmHya](https://discord.gg/RaN5kYmHya)
- **Release Archive:** [https://github.com/OrdexCoin/Ordexcoin-Core/releases](https://github.com/OrdexCoin/Ordexcoin-Core/releases)
- **Issue Tracker:** [https://github.com/OrdexCoin/Ordexcoin-Core/issues](https://github.com/OrdexCoin/Ordexcoin-Core/issues)

---

## License

OrdexCoin Core is released under the terms of the **MIT License**. See [`COPYING`](COPYING) or [https://opensource.org/licenses/MIT](https://opensource.org/licenses/MIT) for details.

This project is built upon the robust foundation of Bitcoin Core. Original copyright © The Bitcoin Core Developers. Modifications and network maintenance © OrdexCoin Core Developers and Shears Mining.
