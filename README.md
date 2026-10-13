<p align="center">
  <a href="https://github.com/nodeal-framework">
    <img src="https://raw.githubusercontent.com/nodeal-framework/.github/main/assets/nodeal.svg" width="200" alt="Nodeal Framework" />
  </a>
</p>

# Nodeal Enhanced Replication

Built for [Nodeal Framework](https://github.com/nodeal-framework) — custom character replication for Roblox + [Nodeal](https://www.nodeal.dev/packages/enhancedrep) (`enhancedrep` v1.1).

Replaces Roblox's default character replication for lower latency.

## How it works

- Client streams `HumanoidRootPart` CFrame + velocity every `PostSimulation` via `EntitySync` (buffered `CFrame`/`Velocity`), destroys the root `WeldConstraint`
- Server tracks each player as a [jecs](https://github.com/Ukendio/jecs) ECS entity (`Position` / `Velocity` / `Rotation` / `Timestamp` / `Owner`), clones the Capsule into the character as `CapsuleReplication`, and drives it in `PreSimulation`
- `Loaded` handshake gates replication until the client signals ready

The Capsule overwrites Roblox's default — instance and code are split below.

## Install

Nodeal: package ID `enhancedrep`.

- Full drag-drop: `assets/enhancedrep/enhancedReplication.rbxmx`
- Or rebuild the hierarchy: ModuleScript `enhancedReplication` with children `jecs` (`src/enhancedrep/jecs.luau`) + `Capsule` (`assets/enhancedrep/Capsule.rbxmx`), source from `src/enhancedrep/init.luau`

Hierarchy must stay `enhancedReplication` with children `jecs` + `Capsule` — code does `require(script.jecs)` and `script.Capsule:Clone()`.

Capsule `MeshPart`: mesh `73706483794360`, 2.63 × 5.64 × 2.63, Transparency 0.5, Anchored, `CanCollide` off, Massless.

## Files

- `src/enhancedrep/init.luau` — main module (`Client` / `Server` / `Init`, branches on `RunService:IsClient()`)
- `src/enhancedrep/jecs.luau` — ECS dependency
- `assets/enhancedrep/Capsule.rbxmx` — Capsule instance only
- `assets/enhancedrep/enhancedReplication.rbxmx` — complete original file

## Notes

- Package: https://www.nodeal.dev/packages/enhancedrep

## License

MIT — see source files for original code.
