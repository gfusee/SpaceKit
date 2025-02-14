<div style="text-align: center;"><img src="https://github.com/gfusee/SpaceKit/blob/master/Sources/SpaceKit/SpaceKit.docc/Resources/Assets/banner.png?raw=true"></div>

[![Version](https://img.shields.io/badge/version-0.2.2-blue.svg)](https://github.com/spacekit/releases)
[![Documentation](https://img.shields.io/badge/docs-available-green.svg)](https://gfusee.github.io/SpaceKit/tutorials/spacekit/)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

# 🚀 SpaceKit: The First Swift Smart Contract Framework

SpaceKit is the **first-ever smart contract framework built for Swift**, bringing a powerful, intuitive, and high-level approach to blockchain development. It is designed to offer a seamless developer experience, making smart contract development as natural as writing Swift applications.

## 🔥 Features

- **Swift-Native Development:** Write smart contracts entirely in Swift with familiar syntax and high-level abstractions.
- **Cross-Platform Support:** Develop on **macOS, Linux, and Windows (via WSL)**.
- **Xcode & VSCode Compatibility:** Use your preferred IDE with full autocompletion and syntax highlighting.
- **Advanced Type System:** High-level types such as `Buffer`, `Vector`, and `BigUint` abstract away low-level operations.
- **Flexible Storage Management:** Use `@Storage` annotations or create custom storage mappers (`WhitelistMapper`, `VecMapper`, `SetMapper`).
- **Easy Contract Interactions:** Deploy, upgrade, or call other contracts seamlessly from your contracts.
- **Async Calls with Callbacks:** Mark functions with `@Callback` for asynchronous calls handling.
- **Full ESDT Support:** Mint, burn, and manage **fungible, non-fungible, and semi-fungible tokens**.
- **Secure Randomness:** Generate random numbers via **SpaceVM’s built-in random features**.
- **Built-in CLI:** Initialize projects, compile to WebAssembly, and generate ABI files.
- **Rust Compatibility:** Swift smart contracts can interact seamlessly with Rust contracts.
- **SwiftVM for Testing:** A Swift-based replica of SpaceVM to test contracts natively with the Swift debugger.

## 🛠 SwiftVM Features

The SwiftVM is a core part of SpaceKit, designed to reproduce the behavior of the SpaceVM directly in a Swift environment. With SwiftVM, you can:

- Run any endpoint of your contract and check its result.
- Handle endpoint failures and view the reason for failure, allowing you to test all edge cases.
- Set the state of each address before running tests, including initializing wallets with token balances.
- Choose which address is calling an endpoint for controlled test execution.
- Simulate payment inputs, including EGLD and ESDT tokens.
- Support synchronous contract-to-contract calls, ensuring state reversion in case of failure.
- Support asynchronous contract-to-contract calls, maintaining non-reverting behavior with callback execution.
- Implement the ESDT GoVM system contract, enabling token issuance and operations.
- Debug efficiently using Xcode’s built-in debugging tools and breakpoints.

---

## 📖 Documentation

For detailed guidance and examples, check out the following resources:

- **[Interactive tutorial & getting started](https://gfusee.github.io/SpaceKit/tutorials/spacekit/)** – Step-by-step instructions on using SpaceKit.
- **[GPT assistant](https://chatgpt.com/g/g-6793b3de291c8191b5dddb67b85b71db-spacekit)** – AI assistant trained to help you using SpaceKit.
- **[Contract examples](https://github.com/gfusee/SpaceKit/tree/master/Examples)** – Ready-to-use contract implementations.
- **[SwiftVM test examples](https://github.com/gfusee/SpaceKit/tree/master/Tests)** – Examples showcasing how to test contracts using SwiftVM.

---

## 📬 Contributing

Contributions are welcome! If you’d like to improve SpaceKit, submit an issue, suggest a feature, or contribute code.

### How to Contribute:
1. Fork the repository.
2. Create a feature branch.
3. Commit changes and push to your fork.
4. Submit a pull request.

Contributing guide is not written yet. Feel free to contact me on [GitHub](https://github.com/gfusee) or [X](https://x.com/gfusee33)!

---

## 📝 License

SpaceKit is licensed under the **GPLv3 License**. See the [LICENSE](https://github.com/spacekit/LICENSE) file for details.

---

## ⚡ Stay Connected

🐦 **Follow on X:** [@gfusee33](https://x.com/gfusee33) for development insights, [@SpaceKitWeb3](https://x.com/SpaceKitWeb3) for official announcements.
