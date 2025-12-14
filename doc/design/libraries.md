# Libraries

| Name                     | Description |
|--------------------------|-------------|
| *libordexcoin_cli*         | RPC client functionality used by *ordexcoin-cli* executable |
| *libordexcoin_common*      | Home for common functionality shared by different executables and libraries. Similar to *libordexcoin_util*, but higher-level (see [Dependencies](#dependencies)). |
| *libordexcoin_consensus*   | Stable, backwards-compatible consensus functionality used by *libordexcoin_node* and *libordexcoin_wallet* and also exposed as a [shared library](../shared-libraries.md). |
| *libordexcoinconsensus*    | Shared library build of static *libordexcoin_consensus* library |
| *libordexcoin_kernel*      | Consensus engine and support library used for validation by *libordexcoin_node* and also exposed as a [shared library](../shared-libraries.md). |
| *libordexcoinqt*           | GUI functionality used by *ordexcoin-qt* and *ordexcoin-gui* executables |
| *libordexcoin_ipc*         | IPC functionality used by *ordexcoin-node*, *ordexcoin-wallet*, *ordexcoin-gui* executables to communicate when [`--enable-multiprocess`](multiprocess.md) is used. |
| *libordexcoin_node*        | P2P and RPC server functionality used by *ordexcoind* and *ordexcoin-qt* executables. |
| *libordexcoin_util*        | Home for common functionality shared by different executables and libraries. Similar to *libordexcoin_common*, but lower-level (see [Dependencies](#dependencies)). |
| *libordexcoin_wallet*      | Wallet functionality used by *ordexcoind* and *ordexcoin-wallet* executables. |
| *libordexcoin_wallet_tool* | Lower-level wallet functionality used by *ordexcoin-wallet* executable. |
| *libordexcoin_zmq*         | [ZeroMQ](../zmq.md) functionality used by *ordexcoind* and *ordexcoin-qt* executables. |

## Conventions

- Most libraries are internal libraries and have APIs which are completely unstable! There are few or no restrictions on backwards compatibility or rules about external dependencies. Exceptions are *libordexcoin_consensus* and *libordexcoin_kernel* which have external interfaces documented at [../shared-libraries.md](../shared-libraries.md).

- Generally each library should have a corresponding source directory and namespace. Source code organization is a work in progress, so it is true that some namespaces are applied inconsistently, and if you look at [`libordexcoin_*_SOURCES`](../../src/Makefile.am) lists you can see that many libraries pull in files from outside their source directory. But when working with libraries, it is good to follow a consistent pattern like:

  - *libordexcoin_node* code lives in `src/node/` in the `node::` namespace
  - *libordexcoin_wallet* code lives in `src/wallet/` in the `wallet::` namespace
  - *libordexcoin_ipc* code lives in `src/ipc/` in the `ipc::` namespace
  - *libordexcoin_util* code lives in `src/util/` in the `util::` namespace
  - *libordexcoin_consensus* code lives in `src/consensus/` in the `Consensus::` namespace

## Dependencies

- Libraries should minimize what other libraries they depend on, and only reference symbols following the arrows shown in the dependency graph below:

<table><tr><td>

```mermaid

%%{ init : { "flowchart" : { "curve" : "basis" }}}%%

graph TD;

ordexcoin-cli[ordexcoin-cli]-->libordexcoin_cli;

ordexcoind[ordexcoind]-->libordexcoin_node;
ordexcoind[ordexcoind]-->libordexcoin_wallet;

ordexcoin-qt[ordexcoin-qt]-->libordexcoin_node;
ordexcoin-qt[ordexcoin-qt]-->libordexcoinqt;
ordexcoin-qt[ordexcoin-qt]-->libordexcoin_wallet;

ordexcoin-wallet[ordexcoin-wallet]-->libordexcoin_wallet;
ordexcoin-wallet[ordexcoin-wallet]-->libordexcoin_wallet_tool;

libordexcoin_cli-->libordexcoin_util;
libordexcoin_cli-->libordexcoin_common;

libordexcoin_common-->libordexcoin_consensus;
libordexcoin_common-->libordexcoin_util;

libordexcoin_kernel-->libordexcoin_consensus;
libordexcoin_kernel-->libordexcoin_util;

libordexcoin_node-->libordexcoin_consensus;
libordexcoin_node-->libordexcoin_kernel;
libordexcoin_node-->libordexcoin_common;
libordexcoin_node-->libordexcoin_util;

libordexcoinqt-->libordexcoin_common;
libordexcoinqt-->libordexcoin_util;

libordexcoin_wallet-->libordexcoin_common;
libordexcoin_wallet-->libordexcoin_util;

libordexcoin_wallet_tool-->libordexcoin_wallet;
libordexcoin_wallet_tool-->libordexcoin_util;

classDef bold stroke-width:2px, font-weight:bold, font-size: smaller;
class ordexcoin-qt,ordexcoind,ordexcoin-cli,ordexcoin-wallet bold
```
</td></tr><tr><td>

**Dependency graph**. Arrows show linker symbol dependencies. *Consensus* lib depends on nothing. *Util* lib is depended on by everything. *Kernel* lib depends only on consensus and util.

</td></tr></table>

- The graph shows what _linker symbols_ (functions and variables) from each library other libraries can call and reference directly, but it is not a call graph. For example, there is no arrow connecting *libordexcoin_wallet* and *libordexcoin_node* libraries, because these libraries are intended to be modular and not depend on each other's internal implementation details. But wallet code is still able to call node code indirectly through the `interfaces::Chain` abstract class in [`interfaces/chain.h`](../../src/interfaces/chain.h) and node code calls wallet code through the `interfaces::ChainClient` and `interfaces::Chain::Notifications` abstract classes in the same file. In general, defining abstract classes in [`src/interfaces/`](../../src/interfaces/) can be a convenient way of avoiding unwanted direct dependencies or circular dependencies between libraries.

- *libordexcoin_consensus* should be a standalone dependency that any library can depend on, and it should not depend on any other libraries itself.

- *libordexcoin_util* should also be a standalone dependency that any library can depend on, and it should not depend on other internal libraries.

- *libordexcoin_common* should serve a similar function as *libordexcoin_util* and be a place for miscellaneous code used by various daemon, GUI, and CLI applications and libraries to live. It should not depend on anything other than *libordexcoin_util* and *libordexcoin_consensus*. The boundary between _util_ and _common_ is a little fuzzy but historically _util_ has been used for more generic, lower-level things like parsing hex, and _common_ has been used for ordexcoin-specific, higher-level things like parsing base58. The difference between util and common is mostly important because *libordexcoin_kernel* is not supposed to depend on *libordexcoin_common*, only *libordexcoin_util*. In general, if it is ever unclear whether it is better to add code to *util* or *common*, it is probably better to add it to *common* unless it is very generically useful or useful particularly to include in the kernel.


- *libordexcoin_kernel* should only depend on *libordexcoin_util* and *libordexcoin_consensus*.

- The only thing that should depend on *libordexcoin_kernel* internally should be *libordexcoin_node*. GUI and wallet libraries *libordexcoinqt* and *libordexcoin_wallet* in particular should not depend on *libordexcoin_kernel* and the unneeded functionality it would pull in, like block validation. To the extent that GUI and wallet code need scripting and signing functionality, they should be get able it from *libordexcoin_consensus*, *libordexcoin_common*, and *libordexcoin_util*, instead of *libordexcoin_kernel*.

- GUI, node, and wallet code internal implementations should all be independent of each other, and the *libordexcoinqt*, *libordexcoin_node*, *libordexcoin_wallet* libraries should never reference each other's symbols. They should only call each other through [`src/interfaces/`](`../../src/interfaces/`) abstract interfaces.

## Work in progress

- Validation code is moving from *libordexcoin_node* to *libordexcoin_kernel* as part of [The libordexcoinkernel Project #24303](https://github.com/ordexcoin/ordexcoin/issues/24303)
- Source code organization is discussed in general in [Library source code organization #15732](https://github.com/ordexcoin/ordexcoin/issues/15732)
