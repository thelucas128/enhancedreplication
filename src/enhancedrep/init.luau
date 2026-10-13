local __ = _G()
local enhancedReplication = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local NetworkService = game:GetService("NetworkService")

local LocalPlayer = Players.LocalPlayer

local jecs = require(script.jecs)
local World = jecs.World.new()

local Position = World:component() :: jecs.Id<Vector3>
local Velocity = World:component() :: jecs.Id<Vector3>
local Rotation = World:component() :: jecs.Id<CFrame>
local Timestamp = World:component() :: jecs.Id<number>
local Owner = World:component() :: jecs.Id<Instance>
local JecsCharacter = World:component() :: jecs.Id<Instance>

local EntitySync = NetworkService:GetNetwork("EntitySync")
EntitySync:SetInterface(buffer.table.u8({
	CFrame = buffer.CFrame.f32,
	Velocity = buffer.Vector3.f32,
}))

local Loaded = NetworkService:GetNetwork("Loaded")

local Loadedplr = {}
local IsClient = RunService:IsClient()

function enhancedReplication.Client()
	LocalPlayer.CharacterAdded:Connect(function(Character)
		local Root = Character:WaitForChild("HumanoidRootPart")
		local WeldConstraint = Root:WaitForChild("WeldConstraint")

		WeldConstraint:Destroy()
	end)

	RunService.PostSimulation:Connect(function()
		local Character = LocalPlayer.Character
		if not Character then return end

		local Root = Character:WaitForChild("HumanoidRootPart") :: Part
		EntitySync:Fire({CFrame = Root.CFrame, Velocity = Root.AssemblyLinearVelocity})
	end)

	if not LocalPlayer.Character then
		LocalPlayer.CharacterAdded:Wait()
	end

	Loaded:Fire()
end

function enhancedReplication.Server()
	Players.PlayerAdded:Connect(function(Player)
		local Entity = World:entity()

		World:set(Entity, Position, Vector3.zero)
		World:set(Entity, Velocity, Vector3.zero)
		World:set(Entity, Rotation, CFrame.identity)
		World:set(Entity, Timestamp, NetworkService:GetSyncedTime())
		World:set(Entity, Owner, Player)

		Player.CharacterAdded:Connect(function(Character)
			repeat
				task.wait()
			until Loadedplr[Player]

			local Root = Character:WaitForChild("HumanoidRootPart")

			local Clone = script.Capsule:Clone()
			Clone.Name = "CapsuleReplication"
			Clone.Anchored = true
			Clone.CanCollide = false
			Clone.CFrame = Root.CFrame
			Clone.Parent = Character

			World:set(Entity, JecsCharacter, Character)
		end)
	end)

	Players.PlayerRemoving:Connect(function(Player)
		for i, v in World:query(Owner) do
			if v == Player then
				World:remove(i)
			end
		end
	end)

	Loaded:OnEvent(function(Header)
		Loadedplr[Header.Player] = true
	end)

	EntitySync:OnEvent(function(Header, Args)
		-- Header.Timestamp is the sender's clock-synced time (set by NetworkService).
		for entity, Owner in World:query(Owner) do
			if Owner == Header.Player then
				World:set(entity, Position, Args.CFrame.Position)
				World:set(entity, Velocity, Args.Velocity)
				World:set(entity, Rotation, Args.CFrame.Rotation)
				World:set(entity, Timestamp, Header.Timestamp)
			end
		end
	end)

	RunService.PreSimulation:Connect(function()
		local now = NetworkService:GetSyncedTime()

		for entity, position, velocity, rotation, timestamp in World:query(Position, Velocity, Rotation, Timestamp) do
			local Character = World:get(entity, JecsCharacter)
			if not Character then continue end

			local CapsulePart = Character:FindFirstChild("CapsuleReplication")
			if not CapsulePart then continue end


			CapsulePart.CFrame = CFrame.new(position) * rotation
		end
	end)
end

function enhancedReplication.Init()
	if IsClient then
		enhancedReplication.Client()
	else
		enhancedReplication.Server()
	end
end

return __(enhancedReplication)
