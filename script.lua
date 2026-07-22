local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

local mouse = player:GetMouse()

local currentSpawnpoint = nil
local checkpointsT = {}


task.spawn(function()
	task.wait(2)
	StarterGui:SetCore("SendNotification", {
		Title = "Kristalina Hub",
		Text = "Made by Kristalik",
		Icon = "rbxassetid://92964845889252",
		Duration = 3,
		Callback = nil,
	})
end)

function healthscript()
	local Players = game:GetService("Players")
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	local StarterGui = game:GetService("StarterGui")
	local player = Players.LocalPlayer
	local plrgui = player.PlayerGui

	local gui = Instance.new("ScreenGui")
	gui.Name = "KRSTALINASHealthGui"
	gui.IgnoreGuiInset = true
	gui.Parent = plrgui
	gui.ResetOnSpawn = false

	local root = Instance.new("Frame") -- Main wrapper
	root.AnchorPoint = Vector2.new(0, 1) -- Bottom-left anchoring behavior
	root.Position = UDim2.new(0, 18, 1, -18) -- Bottom-left offset (padding)
	root.Size = UDim2.new(0, 340, 0, 74) -- Overall size of the UI
	root.BackgroundColor3 = Color3.fromRGB(15, 18, 26) -- Dark tech background
	root.Name = "Root"
	root.Parent = gui

	local uicorner = Instance.new("UICorner", root)
	uicorner.CornerRadius = UDim.new(0, 10)
	local stroke = Instance.new("UIStroke", root)
	stroke.Color = Color3.fromRGB(90, 220, 255)
	stroke.Thickness = 2
	stroke.Transparency = 0.7

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 255)), -- Magenta
		ColorSequenceKeypoint.new(0.20, Color3.fromRGB(0, 255, 255)), -- Cyan
		ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 255, 0)),   -- Green
		ColorSequenceKeypoint.new(0.60, Color3.fromRGB(255, 255, 0)), -- Yellow
		ColorSequenceKeypoint.new(0.80, Color3.fromRGB(255, 0, 0)),   -- Red
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 255)), -- Magenta
	}
	gradient.Rotation = 45
	gradient.Parent = stroke

	local success, result = pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
	end)

	-- Padding inside root so inner content doesn't touch edges
	local pad = Instance.new("UIPadding", root) -- Inner padding component
	pad.PaddingTop = UDim.new(0, 10) -- Top padding
	pad.PaddingBottom = UDim.new(0, 10) -- Bottom padding
	pad.PaddingLeft = UDim.new(0, 10) -- Left padding
	pad.PaddingRight = UDim.new(0, 10) -- Right padding

	-- Mobile-friendly scaling
	local uiScale = Instance.new("UIScale", root) -- Scales entire root for different screens
	uiScale.Scale = 1 -- Default scale (desktop) 	maxmimo

	-- Function to scale based on screen width (simple responsive behavior)
	local function applyScale()
		local cam = workspace.CurrentCamera -- Current rendering camera
		if not cam then return end -- If no camera yet, do nothing
		local w = cam.ViewportSize.X -- Screen width in pixels
		local target = 1 -- Default scale
		if w < 700 then -- Small screens (phones)
			target = 0.85 -- Scale down a bit
		elseif w < 900 then -- Tablets/smaller window
			target = 0.95 -- Slight scale down
		end
		uiScale.Scale = target -- Apply scale
	end

	applyScale() -- Apply once at start
	RunService.RenderStepped:Connect(applyScale) -- Update on resize / device changes

	-- Left icon container (heart background)
	local iconWrap = Instance.new("Frame") -- Icon frame
	iconWrap.Name = "IconWrap" -- Helpful name
	iconWrap.Parent = root -- Inside root
	iconWrap.Size = UDim2.new(0, 54, 0, 54) -- Icon box size
	iconWrap.BackgroundColor3 = Color3.fromRGB(20, 24, 34) -- Slightly lighter than root
	iconWrap.BackgroundTransparency = 0.10 -- Subtle transparency
	iconWrap.BorderSizePixel = 0 -- No border

	-- Rounded corners for iconWrap
	Instance.new("UICorner", iconWrap).CornerRadius = UDim.new(0, 18) -- Round icon box

	-- Outline for iconWrap
	local iconStroke = Instance.new("UIStroke", iconWrap) -- Border around heart box
	iconStroke.Color = Color3.fromRGB(90, 220, 255) -- Cyan outline
	iconStroke.Thickness = 2 -- Thickness
	iconStroke.Transparency = 0.55 -- Slightly more visible than root

	-- Heart icon (text-based so no external assets needed)
	local heart = Instance.new("TextLabel") -- Heart icon label
	heart.Parent = iconWrap -- Put inside iconWrap
	heart.BackgroundTransparency = 1 -- No label background
	heart.Size = UDim2.new(1, 0, 1, 0) -- Fill iconWrap
	heart.Font = Enum.Font.GothamBlack -- Bold, clean font
	heart.Text = "❤" -- Heart character
	heart.TextSize = 30 -- Icon size
	heart.TextColor3 = Color3.fromRGB(255, 90, 100) -- Pinkish red heart

	-- Scale controller for heartbeat animation
	local heartScale = Instance.new("UIScale") -- Scale component for heart
	heartScale.Parent = heart -- Attach to heart label
	heartScale.Scale = 1 -- Default size

	-- Bar container frame (holds lag bar + actual bar)
	local barWrap = Instance.new("Frame") -- Health bar wrapper
	barWrap.Name = "BarWrap" -- Helpful name
	barWrap.Parent = root -- Inside root
	barWrap.Position = UDim2.new(0, 64, 0, 8) -- Right of heart + top aligned
	barWrap.Size = UDim2.new(1, -64, 0, 30) -- Takes remaining width
	barWrap.BackgroundColor3 = Color3.fromRGB(10, 12, 18) -- Deep background
	barWrap.BackgroundTransparency = 0.10 -- Subtle transparency
	barWrap.BorderSizePixel = 0 -- No border

	-- Rounded corners for barWrap
	Instance.new("UICorner", barWrap).CornerRadius = UDim.new(0, 14) -- Rounded bar container

	-- Subtle stroke on bar background
	local barBackStroke = Instance.new("UIStroke", barWrap) -- Border around bar container
	barBackStroke.Color = Color3.fromRGB(40, 46, 66) -- Dark border
	barBackStroke.Thickness = 2 -- Thickness
	barBackStroke.Transparency = 0.6 -- Subtle

	-- Lag bar (damage delay effect) - sits behind main bar
	local lagBar = Instance.new("Frame") -- Lag bar frame
	lagBar.Name = "LagBar" -- Helpful name
	lagBar.Parent = barWrap -- Inside barWrap
	lagBar.Size = UDim2.new(1, 0, 1, 0) -- Start full width (will be set)
	lagBar.BackgroundColor3 = Color3.fromRGB(255, 170, 80) -- Orange damage trail
	lagBar.BackgroundTransparency = 0.35 -- Semi-transparent
	lagBar.BorderSizePixel = 0 -- No border

	-- Rounded corners for lagBar
	Instance.new("UICorner", lagBar).CornerRadius = UDim.new(0, 14) -- Rounded lag bar

	-- Actual health bar (front bar)
	local bar = Instance.new("Frame") -- Main health fill
	bar.Name = "Bar" -- Helpful name
	bar.Parent = barWrap -- Inside barWrap
	bar.Size = UDim2.new(1, 0, 1, 0) -- Start full width
	bar.BackgroundColor3 = Color3.fromRGB(80, 255, 140) -- Default green
	bar.BackgroundTransparency = 0 -- Opaque
	bar.BorderSizePixel = 0 -- No border

	-- Rounded corners for main bar
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 14) -- Rounded fill

	-- Static gloss overlay for depth (not animated)
	local gloss = Instance.new("Frame") -- Gloss layer
	gloss.Parent = bar -- On top of fill
	gloss.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White highlight
	gloss.BackgroundTransparency = 0.88 -- Very subtle
	gloss.BorderSizePixel = 0 -- No border
	gloss.Size = UDim2.new(1, 0, 0.45, 0) -- Top portion only

	-- Rounded corners for gloss (matches bar)
	Instance.new("UICorner", gloss).CornerRadius = UDim.new(0, 14) -- Same rounding

	-- Gradient fill for premium look
	local barGrad = Instance.new("UIGradient") -- Gradient component
	barGrad.Parent = bar -- Attach to bar
	barGrad.Rotation = 0 -- Horizontal gradient
	barGrad.Color = ColorSequence.new{ -- Default green-ish gradient
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 255, 210)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 255, 140)),
	}
	barGrad.Offset = Vector2.new(0, 0) -- Starting offset

	-- Text label showing "current/max" health
	local valueLabel = Instance.new("TextLabel") -- Health value text
	valueLabel.Name = "Value" -- Helpful name
	valueLabel.Parent = root -- Inside root
	valueLabel.Position = UDim2.new(0, 64, 0, 42) -- Under the bar
	valueLabel.Size = UDim2.new(1, -64, 0, 22) -- Full width minus heart
	valueLabel.BackgroundTransparency = 1 -- No background
	valueLabel.Font = Enum.Font.GothamBold -- Clean bold font
	valueLabel.Text = "0/0" -- Default
	valueLabel.TextSize = 18 -- Readable size
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left -- Left aligned
	valueLabel.TextColor3 = Color3.fromRGB(220, 245, 255) -- Light tech text

	-- Warning glow behind root for low HP
	local warningGlow = Instance.new("Frame") -- Glow overlay
	warningGlow.Name = "WarningGlow" -- Helpful name
	warningGlow.Parent = root -- Behind/under root
	warningGlow.BackgroundColor3 = Color3.fromRGB(255, 60, 80) -- Red glow
	warningGlow.BackgroundTransparency = 1 -- Hidden by default
	warningGlow.BorderSizePixel = 0 -- No border
	warningGlow.Size = UDim2.new(1, 0, 1, 0) -- Same size as root
	warningGlow.ZIndex = root.ZIndex - 1 -- Render behind root
	Instance.new("UICorner", warningGlow).CornerRadius = UDim.new(0, 20) -- Same rounding

	-- =========================
	-- TWEEN HELPERS (smooth animations)
	-- =========================

	-- Helper to create and play tweens quickly
	local function tween(obj, ti, props)
		local t = TweenService:Create(obj, ti, props) -- Build tween
		t:Play() -- Start tween
		return t -- Return tween for Completed:Wait if needed
	end

	-- Tween presets
	local tiFast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) -- Snappy
	local tiSmooth = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) -- Smooth
	local tiLag = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) -- Slow catch-up

	-- =========================
	-- VISUAL FX (damage flash + warning)
	-- =========================

	-- Quick feedback on damage: stroke flash + tiny shake
	local function damageFlash()
		tween(stroke, tiFast, {Transparency = 0.25}) -- Highlight border
		tween(iconStroke, tiFast, {Transparency = 0.20}) -- Highlight icon border
		tween(root, tiFast, {Position = UDim2.new(0, 21, 1, -20)}) -- Tiny nudge (shake)

		task.delay(0.08, function() -- Reset shortly after
			tween(stroke, tiFast, {Transparency = 0.7}) -- Back to normal
			tween(iconStroke, tiFast, {Transparency = 0.55}) -- Back to normal
			tween(root, tiFast, {Position = UDim2.new(0, 18, 1, -18)}) -- Back to base pos
		end)
	end

	-- Low HP glow behind root (only when alive)
	local function lowHpWarn(enable: boolean)
		if enable then
			tween(warningGlow, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0.85}) -- Show
		else
			tween(warningGlow, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1}) -- Hide
		end
	end

	-- =========================
	-- HEALTH STATE + UI UPDATES
	-- =========================

	local humanoid: Humanoid? = nil -- Bound humanoid reference
	local lastHealth = 0 -- Previous health value for change detection

	-- Update bar colors + gradient based on health percentage
	local function setBarColor(pct: number)
		if pct > 0.55 then -- High health
			bar.BackgroundColor3 = Color3.fromRGB(80, 255, 140) -- Green
			barGrad.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 255, 210)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 255, 140)),
			}
		elseif pct > 0.25 then -- Mid health
			bar.BackgroundColor3 = Color3.fromRGB(255, 210, 90) -- Yellow
			barGrad.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 230, 120)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 190, 80)),
			}
		else -- Low health
			bar.BackgroundColor3 = Color3.fromRGB(255, 90, 100) -- Red
			barGrad.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 140, 150)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 70, 90)),
			}
		end
	end

	-- Set lag bar size with a crucial FIX:
	-- when pct <= 0, hide lag bar completely to avoid the “red remainder” look
	local function setLagBarPct(pct: number, animated: boolean)
		pct = math.clamp(pct, 0, 1) -- Clamp to valid range
		if pct <= 0 then -- Dead / empty
			lagBar.Size = UDim2.new(0, 0, 1, 0) -- Force empty
			lagBar.Visible = false -- Hide completely
			return -- Exit
		end
		lagBar.Visible = true -- Ensure visible when > 0
		if animated then -- Smooth catch-up
			tween(lagBar, tiLag, {Size = UDim2.new(pct, 0, 1, 0)}) -- Animate size
		else -- Immediate set
			lagBar.Size = UDim2.new(pct, 0, 1, 0) -- Set size
		end
	end

	-- Set main bar size (smooth or instant)
	local function setBarPct(pct: number, animated: boolean)
		pct = math.clamp(pct, 0, 1) -- Clamp
		if animated then
			tween(bar, tiSmooth, {Size = UDim2.new(pct, 0, 1, 0)}) -- Smooth size change
		else
			bar.Size = UDim2.new(pct, 0, 1, 0) -- Instant change
		end
	end

	-- Full UI update based on current + max health
	local function updateUI(cur: number, max: number, instant: boolean)
		if max <= 0 then return end -- Avoid division by zero

		cur = math.max(cur, 0) -- Never below 0
		local pct = math.clamp(cur / max, 0, 1) -- Percent health

		valueLabel.Text = string.format("%d/%d", math.floor(cur + 0.5), math.floor(max + 0.5)) -- Update text
		setBarColor(pct) -- Update colors

		setBarPct(pct, not instant) -- Update main bar (smooth unless instant)
		if instant then
			setLagBarPct(pct, false) -- Align lag bar instantly on first bind
		end

		-- Low HP glow only when alive and low
		if pct > 0 and pct <= 0.25 then
			lowHpWarn(true) -- Show warning
		else
			lowHpWarn(false) -- Hide warning
		end

		-- Death look: slightly fade fill when empty (clean)
		if pct <= 0 then
			tween(bar, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.25}) -- Fade a bit
		else
			tween(bar, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}) -- Full visible
		end
	end

	-- =========================
	-- HUMANOID BINDING
	-- =========================

	-- Bind to a humanoid and connect health events
	local function bindHumanoid(h: Humanoid)
		humanoid = h -- Store reference
		lastHealth = h.Health -- Save initial

		updateUI(h.Health, h.MaxHealth, true) -- Initial paint (instant)

		-- When health changes (damage/heal)
		h.HealthChanged:Connect(function(newHealth)
			if not humanoid then return end -- Safety
			local max = humanoid.MaxHealth -- Current max
			local prev = lastHealth -- Previous
			lastHealth = newHealth -- Update stored

			updateUI(newHealth, max, false) -- Update UI smoothly

			local pctNew = math.clamp(math.max(newHealth, 0) / max, 0, 1) -- New percent
			local pctPrev = math.clamp(math.max(prev, 0) / max, 0, 1) -- Prev percent

			if newHealth < prev then -- DAMAGE case
				damageFlash() -- Hit feedback

				if pctNew <= 0 then -- If dead now
					setLagBarPct(0, false) -- Kill lag bar instantly (fix)
					return -- Done
				end

				-- Hold lag bar at previous percent briefly
				setLagBarPct(pctPrev, false) -- Set lag to old value immediately

				-- Then ease it down after short delay
				task.delay(0.08, function()
					if humanoid then -- Safety check
						local nowPct = math.clamp(math.max(humanoid.Health, 0) / humanoid.MaxHealth, 0, 1) -- Current
						setLagBarPct(nowPct, true) -- Animate lag down to current
					end
				end)
			else
				-- HEAL case: we intentionally do NOT do “revive/shine” effects
				-- Keep lag bar synced immediately (clean)
				setLagBarPct(pctNew, false) -- Snap lag to new value
			end
		end)

		-- If MaxHealth changes (buffs/debuffs)
		h:GetPropertyChangedSignal("MaxHealth"):Connect(function()
			if not humanoid then return end -- Safety
			updateUI(humanoid.Health, humanoid.MaxHealth, false) -- Recompute percent + UI

			local pct = math.clamp(math.max(humanoid.Health, 0) / humanoid.MaxHealth, 0, 1) -- Current percent
			if pct <= 0 then
				setLagBarPct(0, false) -- Hide lag on 0
			else
				setLagBarPct(pct, true) -- Animate to new percent
			end
		end)
	end

	-- Find Humanoid in a character and bind it
	local function tryBindFromCharacter(char: Model)
		local h = char:FindFirstChildOfClass("Humanoid") -- Try immediate
		if not h then
			h = char:WaitForChild("Humanoid", 10) -- Wait up to 10s
		end
		if h and h:IsA("Humanoid") then
			bindHumanoid(h) -- Bind
		else
			warn("HealthBar: No Humanoid found.") -- Debug warning
		end
	end

	-- Re-bind when character respawns
	player.CharacterAdded:Connect(function(char)
		task.wait(0.05) -- Small delay to ensure Humanoid exists
		tryBindFromCharacter(char) -- Bind new character
	end)

	-- Bind immediately if already spawned
	if player.Character then
		tryBindFromCharacter(player.Character) -- Bind now
	end

	-- =========================
	-- PREMIUM MOTION: GRADIENT DRIFT (subtle)
	-- =========================

	-- Loop to slowly move gradient offset left/right for life in the bar
	task.spawn(function()
		while bar and bar.Parent do -- While UI exists
			local t1 = tween(barGrad, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Offset = Vector2.new(0.12, 0)}) -- Move right
			t1.Completed:Wait() -- Wait finish
			local t2 = tween(barGrad, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Offset = Vector2.new(-0.12, 0)}) -- Move left
			t2.Completed:Wait() -- Wait finish
		end
	end)

	-- =========================
	-- HEART BEAT: ALWAYS (faster at low HP), stop on 0
	-- =========================

	-- Loop that continuously “beats” the heart with variable speed based on HP percentage
	task.spawn(function()
		while gui and gui.Parent do -- While ScreenGui exists
			task.wait(0.05) -- Small pacing

			if humanoid and humanoid.MaxHealth > 0 then -- Only if bound
				local pct = humanoid.Health / humanoid.MaxHealth -- Health percentage

				if pct <= 0 then -- Dead
					-- Reset heart scale and pause (no pulsing while dead)
					if math.abs(heartScale.Scale - 1) > 0.01 then -- If not normal size
						tween(heartScale, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Scale = 1}) -- Reset
					end
					task.wait(0.25) -- Pause while dead
				else
					-- Speed mapping:
					-- Higher HP => slower beat, lower HP => faster beat
					local beat = 0.22 + (pct * 0.65) -- 0.22..0.87 seconds for a full beat cycle
					local upTime = beat * 0.45 -- Time for “expand”
					local downTime = beat * 0.55 -- Time for “contract”

					-- Amplitude mapping:
					-- Low HP => stronger pulse
					local amp = 1.04 + (1 - pct) * 0.06 -- 1.04..1.10

					-- Expand (heartbeat up)
					local up = tween(heartScale, TweenInfo.new(upTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Scale = amp})
					up.Completed:Wait() -- Wait finish

					-- Contract (heartbeat down)
					local down = tween(heartScale, TweenInfo.new(downTime, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Scale = 1})
					down.Completed:Wait() -- Wait finish
				end
			else
				task.wait(0.25) -- If no humanoid yet, wait
			end
		end
	end)

end

function bikerscript()
	--,eta
end


function naoyascript()

	-- ======================= CREDITS & LOADING =======================
	local function showCredits()
		StarterGui:SetCore("SendNotification", {
			Title = "Naoya Zenin. Script",
			Text = "v2 by KR, made by nagizaronagi, inspiration: sa*avrilchuk1",
			Icon = "rbxassetid://89102547687130",
			Duration = 3,
			Callback = nil,
		})
	end
	task.spawn(showCredits)

	-- ======================= SETTINGS =======================
	local SETTINGS = {
		PROJ_COLOR = Color3.fromRGB(85, 130, 255),
		PROJ_TR = 0.7,
		MAX_Z_FPS = 24,
		Z_STEP_DISTANCE = 5,
		Z_SPEED_MULTIPLIER = 1,
		RAMP_TIME = 10,
		X_LOCK_DIST = 120, -- Max distance to find a target for X
		C_DASH_DIST = 100,
		FLING_FORCE = 300,
		V_BURST_SPEED = 140,
		V_BURST_ACCEL = 8,
		TOP_SPEED_MAX = 1000,
		TOP_SPEED_ACCEL = 200
	}

	local isProjActive, isBusy = false, false
	local savedFrames = {}
	local ghostCF = CFrame.new()
	local currentTimer = 0 
	local scriptRunning = true

	local fxFolder = workspace:FindFirstChild("ZeninFX") or Instance.new("Folder", workspace)
	fxFolder.Name = "ZeninFX"

	-- ======================= UI SETUP =======================
	local function setupUI()
		local sg = Instance.new("ScreenGui", playerGui)
		sg.Name = "ZeninUI"

		local kill = Instance.new("TextButton", sg)
		kill.Size = UDim2.new(0, 140, 0, 40)
		kill.Position = UDim2.new(1, -150, 0, 0)
		kill.BackgroundColor3 = Color3.new(0.5, 0, 0)
		kill.Text = "STOP SCRIPT"
		kill.TextColor3 = Color3.new(1, 1, 1)
		kill.MouseButton1Click:Connect(function()
			scriptRunning = false
			ContextActionService:UnbindAction("Z_Action")
			ContextActionService:UnbindAction("X_Action")
			ContextActionService:UnbindAction("C_Action")
			ContextActionService:UnbindAction("V_Action")
			ContextActionService:UnbindAction("B_Action")
			ContextActionService:UnbindAction("F_Action")
			ContextActionService:UnbindAction("T_Action")
			fxFolder:ClearAllChildren()
			sg:Destroy()
		end)

		local function createSetting(parent, name, key, yPos)
			local frame = Instance.new("Frame", parent)
			frame.Size = UDim2.new(0, 300, 0, 40)
			frame.Position = UDim2.new(0, 0, 0, yPos)
			frame.BackgroundTransparency = 1

			local label = Instance.new("TextLabel", frame)
			label.Size = UDim2.new(0.5, 0, 1, 0)
			label.Text = name
			label.TextColor3 = Color3.new(1,1,1)
			label.BackgroundTransparency = 1

			local box = Instance.new("TextBox", frame)
			box.Size = UDim2.new(0.5, 0, 1, 0)
			box.Position = UDim2.new(0.5, 0, 0, 0)
			box.Text = tostring(SETTINGS[key])
			box.TextColor3 = SETTINGS.PROJ_COLOR
			box.BackgroundColor3 = Color3.new(0,0,0)

			box.FocusLost:Connect(function()
				local val = tonumber(box.Text)
				if val then
					SETTINGS[key] = val
				else
					box.Text = tostring(SETTINGS[key])
				end
			end)
		end

    --[[local menu = Instance.new("Frame", sg)
    menu.Size = UDim2.new(0, 350, 0, 60)
    menu.Position = UDim2.new(0, 20, 0.85, 0)
    menu.BackgroundColor3 = Color3.new(0,0,0)
    menu.BorderColor3 = SETTINGS.PROJ_COLOR

	local title = Instance.new("TextLabel", menu)
    title.Size = UDim2.new(1,0,0.4,0)
    title.Text = "MAX FPS (Z)"
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 1

    local input = Instance.new("TextBox", menu)
    input.Size = UDim2.new(0.8,0,0.4,0)
    input.Position = UDim2.new(0.1,0,0.5,0)
    input.Text = tostring(SETTINGS.MAX_Z_FPS)
    input.TextColor3 = SETTINGS.PROJ_COLOR
    input.FocusLost:Connect(function() 
        SETTINGS.MAX_Z_FPS = tonumber(input.Text) or 24 
    end)]]

		local controls = Instance.new("Frame", sg)
		controls.Size = UDim2.new(0, 300, 0, 400)
		controls.Position = UDim2.new(0.6, 0, 0.3, 0)
		controls.BackgroundTransparency = 1

		local inText = Instance.new("TextLabel", controls)
		inText.Size = UDim2.new(1,0,1,0)
		inText.BackgroundTransparency = 1
		inText.TextColor3 = Color3.new(255,255,255)
		inText.Text = "Z - Projection set (Hold), \n X - Dash and Fling target (Nearest player), \n C - Free Dash, \n V - Burst, B - Boost (during Z), \n F - Air Step, \n T - Top Speed"
		inText.TextScaled = true

		local settingsFrame = Instance.new("Frame", sg)
		settingsFrame.Size = UDim2.new(0, 400, 0, 850)
		settingsFrame.Position = UDim2.new(0, 20, 0.2, 0)
		settingsFrame.BackgroundColor3 = Color3.new(0,0,0)

		createSetting(settingsFrame, "Max Z FPS", "MAX_Z_FPS", 0)
		createSetting(settingsFrame, "Ramp Time", "RAMP_TIME", 40)
		createSetting(settingsFrame, "Dash Distance", "C_DASH_DIST", 80)
		createSetting(settingsFrame, "Fling Force", "FLING_FORCE", 120)
		createSetting(settingsFrame, "Z Step Distance", "Z_STEP_DISTANCE", 160)
		createSetting(settingsFrame, "Z Speed Multiplier", "Z_SPEED_MULTIPLIER", 200)
		createSetting(settingsFrame, "V Burst Speed", "V_BURST_SPEED", 240)
		createSetting(settingsFrame, "V Burst Acceleration", "V_BURST_ACCEL", 280)
		createSetting(settingsFrame, "Top Speed Max", "TOP_SPEED_MAX", 320)
		createSetting(settingsFrame, "Top Sped Acceleration", "TOP_SPEED_ACCEL", 360)
	end
	setupUI()

	local function getGroundedCF(pos, direction)
		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {character, fxFolder}
		rayParams.FilterType = Enum.RaycastFilterType.Blacklist

		local rayOrigin = pos + Vector3.new(0, 10, 0)
		local rayDir = Vector3.new(0, -50, 0)

		local result = workspace:Raycast(rayOrigin, rayDir, rayParams)

		if result then
			local normal = result.Normal

			-- height offset so you don't sink
			local heightOffset = humanoid.HipHeight + (hrp.Size.Y / 2)

			local groundedPos = result.Position + Vector3.new(0, heightOffset, 0)

			-- project movement onto slope
			local moveDir = direction.Unit
			--local slopeMove = (moveDir - normal * moveDir:Dot(normal)).Unit

			local slope = (moveDir - normal * moveDir:Dot(normal))
			if slope.Magnitude < 0.1 then
				slope = moveDir
			end
			local slopeMove = slope.Unit

			return CFrame.lookAt(groundedPos, groundedPos + slopeMove)
		else
			return CFrame.new(pos)
		end
	end

	-- ======================= UTILS =======================

	local function capturePose()
		local p = {}
		for _, m in ipairs(character:GetDescendants()) do
			if m:IsA("Motor6D") then p[m.Name] = m.Transform end
		end
		return p
	end

	local function applyPose(pose, dur)
		local c = RunService.PreSimulation:Connect(function()
			for name, trans in pairs(pose) do
				local motor = character:FindFirstChild(name, true)
				if motor then motor.Transform = trans end
			end
		end)
		task.delay(dur, function() c:Disconnect() end)
	end

	local function createGhostModel(cf, trans, autoDestroy)
		local m = Instance.new("Model", fxFolder)
		for _, p in ipairs(character:GetChildren()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
				local c = p:Clone() c:ClearAllChildren()
				c.Anchored, c.CanCollide = true, false
				c.Material, c.Color, c.Transparency = Enum.Material.Neon, SETTINGS.PROJ_COLOR, trans
				c.CFrame = cf * (hrp.CFrame:Inverse() * p.CFrame)
				c.Parent = m
			end
		end
		if autoDestroy then task.delay(2, function() if m then m:Destroy() end end) end
	end

	local colorCorr = Instance.new("ColorCorrectionEffect", Lighting)

	colorCorr.TintColor = Color3.fromRGB(165, 190, 255)
	colorCorr.Brightness = 0.2
	colorCorr.Saturation = -0.3
	colorCorr.Contrast = 0.3
	colorCorr.Enabled = false


	-- ======================= ABILITIES =======================

	-- Z: PROJECTION (Speed scales with FPS)
	local function handleZ(name, state)
		if not scriptRunning then return end
		if state == Enum.UserInputState.Begin then
			if isProjActive or isBusy then return end
			fxFolder:ClearAllChildren() 
			isProjActive, savedFrames, currentTimer = true, {}, 0
			hrp.Anchored = true
			isBusy = true
			ghostCF = hrp.CFrame
			local camPart = Instance.new("Part", fxFolder)
			camPart.Transparency, camPart.Anchored, camPart.CanCollide = 1, true, false
			camPart.CFrame = hrp.CFrame
			task.wait()
			camera.CameraSubject = camPart

			colorCorr.Enabled = true

			task.spawn(function()
				local logicTimer = 0
				while isProjActive and scriptRunning do
					local dt = RunService.Heartbeat:Wait()
					currentTimer += dt
					local progress = math.min(currentTimer / SETTINGS.RAMP_TIME, 1)
					local currentFPS = 1 + (progress * (SETTINGS.MAX_Z_FPS - 1))
					local interval = 1 / currentFPS
					logicTimer += dt
					if logicTimer >= interval then
						logicTimer = 0
						local move = humanoid.MoveDirection
						if move.Magnitude > 0 then
							local speedMultiplier = (currentFPS / 10) * 12 
							local stepBase = tonumber(SETTINGS.Z_STEP_DISTANCE) or 5
							local multiplier = tonumber(SETTINGS.Z_SPEED_MULTIPLIER) or 1
							--v1 ghostCF = ghostCF + (move * (5 + speedMultiplier))
							--v1.5 local nextPos = ghostCF.Position + (move * (5 + speedMultiplier))
							local step = stepBase + speedMultiplier
							local nextPos = ghostCF.Position + (move * step * multiplier)
							ghostCF = getGroundedCF(nextPos, move)
							createGhostModel(ghostCF, SETTINGS.PROJ_TR, false) 
						end
						camPart.CFrame = ghostCF
						table.insert(savedFrames, {cf = ghostCF, pose = capturePose(), t = interval})
					end
				end
				camPart:Destroy()
			end)
		elseif state == Enum.UserInputState.End and isProjActive then
			colorCorr.Enabled = false
			isProjActive = false
			hrp.Anchored = false
			camera.CameraSubject = humanoid
			local replay = savedFrames
			task.spawn(function()
				humanoid.AutoRotate = false
				for _, data in ipairs(replay) do
					if not scriptRunning then break end
					hrp.CFrame = data.cf
					applyPose(data.pose, data.t)
					task.wait(data.t)
				end
				humanoid.AutoRotate = true
				fxFolder:ClearAllChildren() 
				isBusy = false
			end)
		end

	end

	-- X: TARGET DASH & FLING (Closest Person)
	local function handleX(name, state)
		if state ~= Enum.UserInputState.Begin or isBusy or not scriptRunning then return end
		local target = nil
		local minDist = SETTINGS.X_LOCK_DIST
		for _, v in ipairs(workspace:GetChildren()) do
			local eHrp = v:FindFirstChild("HumanoidRootPart")
			if v ~= character and eHrp and (hrp.Position - eHrp.Position).Magnitude < minDist then
				target = eHrp
				minDist = (hrp.Position - eHrp.Position).Magnitude
			end
		end

		if not target then return end
		isBusy, hrp.Anchored = true, true
		local startPos = hrp.Position
		local endPos = target.Position + (hrp.Position - target.Position).Unit * 3

		for i = 0, 1, 0.1 do
			hrp.CFrame = CFrame.lookAt(startPos:Lerp(endPos, i), target.Position)
			createGhostModel(hrp.CFrame, SETTINGS.PROJ_TR, true)
			task.wait(0.01)
		end

		local eHum = target.Parent:FindFirstChildOfClass("Humanoid")
		if eHum then
			eHum.PlatformStand = true
			target.AssemblyLinearVelocity = (target.Position - hrp.Position).Unit * SETTINGS.FLING_FORCE + Vector3.new(0, 50, 0)
			task.delay(2, function() if eHum then eHum.PlatformStand = false end end)
		end

		hrp.Anchored, isBusy = false, false
	end
	local holdingC = false
	-- C: FREE DASH
	local function handleC(name, state)
	--[[v1 if state ~= Enum.UserInputState.Begin or isBusy or not scriptRunning then return end
	isBusy, hrp.Anchored = true, true
    local dashDir = humanoid.MoveDirection.Magnitude > 0 and humanoid.MoveDirection or hrp.CFrame.LookVector
	for i = 1, 20 do
		hrp.CFrame = hrp.CFrame + (dashDir * (SETTINGS.C_DASH_DIST / 20))
		createGhostModel(hrp.CFrame, 0.4, true)
		task.wait(0.01)
	end
	hrp.Anchored, isBusy = false, false]]

		if not scriptRunning then return end

		if state == Enum.UserInputState.Begin then
			if isBusy then return end
			holdingC = true
			isBusy = true

			task.spawn(function()
				while holdingC do
					local dir = humanoid.MoveDirection.Magnitude > 0 and humanoid.MoveDirection or hrp.CFrame.LookVector

					hrp.CFrame = hrp.CFrame + (dir * (SETTINGS.C_DASH_DIST / 10))
					createGhostModel(hrp.CFrame, SETTINGS.PROJ_TR, true)

					RunService.Heartbeat:Wait()
				end

				isBusy = false
			end)

		elseif state == Enum.UserInputState.End then
			holdingC = false
		end
	end

	-- V: BURST (Stacking Speed)
	local holdingV = false
	local vVelocity = 0
	local vConn = nil

	local function handleV(name, state)
		if not scriptRunning then return end

		if state == Enum.UserInputState.Begin then
			if holdingV or isBusy then return end
			isBusy = true
			holdingV = true

			vVelocity = SETTINGS.V_BURST_SPEED
			fxFolder:ClearAllChildren()

			local lastMove = Vector3.zero

			vConn = RunService.Heartbeat:Connect(function(dt)
				local move = humanoid.MoveDirection
				if move.Magnitude > 0 then
					lastMove = move
				end

				-- accelerate slightly while holding
				vVelocity += SETTINGS.V_BURST_ACCEL * dt

				local direction = (lastMove.Magnitude > 0 and lastMove or hrp.CFrame.LookVector)

				local nextPos = hrp.Position + (direction * vVelocity * dt)

				local groundedCF = getGroundedCF(nextPos, direction)

				hrp.CFrame = groundedCF

				-- light trail only (safe, no logic dependency)
				createGhostModel(groundedCF, SETTINGS.PROJ_TR, true)

			end)
		elseif state == Enum.UserInputState.End then
			holdingV = false

			if vConn then
				vConn:Disconnect()
				vConn = nil
			end

			-- hard stop
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero

			task.delay(0.1, function()
				isBusy = false
			end)
		end
	end

	-- B: BOOST (Instant Max while in Z)
	local function handleB(name, state)
		if state ~= Enum.UserInputState.Begin or not scriptRunning then return end
		if isProjActive then
			currentTimer = SETTINGS.RAMP_TIME
			local boom = Instance.new("Part", fxFolder)
			boom.Size, boom.CFrame, boom.Shape = Vector3.new(5,5,5), ghostCF, "Ball"
			boom.Anchored, boom.CanCollide, boom.Material, boom.Color = true, false, "Neon", SETTINGS.PROJ_COLOR
			TweenService:Create(boom, TweenInfo.new(0.5), {Size = Vector3.new(25,25,25), Transparency = 1}):Play()
			task.delay(0.5, function() boom:Destroy() end)
		end
	end

	-- F: AIR STEP (GO UP)
	local function handleF(name, state)
		if state ~= Enum.UserInputState.Begin or isBusy or not scriptRunning then return end

		isBusy = true

		-- upward + forward boost
		local dir = humanoid.MoveDirection.Magnitude > 0 and humanoid.MoveDirection or hrp.CFrame.LookVector
		local velocity = dir * 60 + Vector3.new(0, 120, 0)

		hrp.AssemblyLinearVelocity = velocity

		local p = Instance.new("Part", fxFolder)
		p.Shape = Enum.PartType.Ball
		p.Size = Vector3.new(3,3,3)
		p.CFrame = hrp.CFrame
		p.Anchored = true
		p.CanCollide = false
		p.Material = Enum.Material.Neon
		p.Color = SETTINGS.PROJ_COLOR

		TweenService:Create(p, TweenInfo.new(0.4), {
			Size = Vector3.new(15,15,15),
			Transparency = 1
		}):Play()

		task.delay(0.4, function() p:Destroy() end)
		task.delay(0.2, function() isBusy = false end)
	end

	local holdingT = false

	-- T: Top Speed (Run super fast)
	local function handleT(name, state)
		if not scriptRunning then return end

		if state == Enum.UserInputState.Begin then
			if isBusy then return end

			holdingT = true
			isBusy = true

			local speed = 0

			task.spawn(function()
				while holdingT do
					local dt = RunService.Heartbeat:Wait()

					local move = humanoid.MoveDirection.Magnitude > 0 
						and humanoid.MoveDirection 
						or hrp.CFrame.LookVector

					-- ramp speed
					speed += SETTINGS.TOP_SPEED_ACCEL * dt
					speed = math.clamp(speed, 0, SETTINGS.TOP_SPEED_MAX)

					hrp.AssemblyLinearVelocity = move.Unit * speed

					createGhostModel(hrp.CFrame, SETTINGS.PROJ_TR - 0.1, true)
				end

				isBusy = false
			end)

		elseif state == Enum.UserInputState.End then
			holdingT = false
		end
	end

	-- ======================= MOBILE BINDS =======================
	local function bind(actionName, func, key, title, pos)
		ContextActionService:BindAction(actionName, func, true, key)
		ContextActionService:SetTitle(actionName, title)
		ContextActionService:SetPosition(actionName, pos)
	end

	bind("Z_Action", handleZ, Enum.KeyCode.Z, "Proj (Z)", UDim2.new(1, -110, 0, 50))
	bind("X_Action", handleX, Enum.KeyCode.X, "Lock Dash (X)", UDim2.new(1, -110, 0, 100))
	bind("C_Action", handleC, Enum.KeyCode.C, "Free Dash (C)", UDim2.new(1, -110, 0, 150))
	bind("V_Action", handleV, Enum.KeyCode.V, "Burst (V)", UDim2.new(1, -110, 0, 200))
	bind("B_Action", handleB, Enum.KeyCode.B, "Boost (B)", UDim2.new(1, -110, 0, 250))
	bind("F_Action", handleF, Enum.KeyCode.F, "Air Step (F)", UDim2.new(1, -110, 0, 300))
	bind("T_Action", handleT, Enum.KeyCode.T, "Top Speed (T)", UDim2.new(1, -110, 0, 350))
end



-- kazlina


function kazescript()
	local scriptRunning = true
	local isBusy = false
	local forms = {
		"Geisha",
		"Ninja"
	}
	local currentForm = forms[1]

	local function showCredits()
		StarterGui:SetCore("SendNotification", {
			Title = "Kaze. Script",
			Text = "by Kristalik",
			Icon = "rbxassetid://128964651764420",
			Duration = 3,
			Callback = nil,
		})
	end
	task.spawn(showCredits)

	local function getGroundedCF(pos, direction)
		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {character, fxFolder}
		rayParams.FilterType = Enum.RaycastFilterType.Blacklist

		local rayOrigin = pos + Vector3.new(0, 10, 0)
		local rayDir = Vector3.new(0, -50, 0)

		local result = workspace:Raycast(rayOrigin, rayDir, rayParams)

		if result then
			local normal = result.Normal

			-- height offset so you don't sink
			local heightOffset = humanoid.HipHeight + (hrp.Size.Y / 2)

			local groundedPos = result.Position + Vector3.new(0, heightOffset, 0)

			-- project movement onto slope
			local moveDir = direction.Unit
			--local slopeMove = (moveDir - normal * moveDir:Dot(normal)).Unit

			local slope = (moveDir - normal * moveDir:Dot(normal))
			if slope.Magnitude < 0.1 then
				slope = moveDir
			end
			local slopeMove = slope.Unit

			return CFrame.lookAt(groundedPos, groundedPos + slopeMove)
		else
			return CFrame.new(pos)
		end
	end


	local SETTINGS = {
		DASH_DISTANCE = 4,
		DASH_TIME = 0.2,
		ULT_DASH_DISTANCE = 10,
		DASH_TIME_ULT = 1,
	}

	local inTexta = Instance.new("TextLabel")

	-- ======================= UI SETUP =======================
	local function setupUI()
		local sg = Instance.new("ScreenGui", playerGui)
		sg.Name = "KazeUI"

		local soundID = "rbxassetid://98117720580991"
		local sound = Instance.new("Sound")
		sound.SoundId = soundID
		sound.Parent = hrp
		sound:Play()

		setRolledUp(false)

		local kill = Instance.new("TextButton", sg)
		kill.Size = UDim2.new(0, 140, 0, 40)
		kill.Position = UDim2.new(1, -150, 0, 0)
		kill.BackgroundColor3 = Color3.new(0.5, 0, 0)
		kill.Text = "STOP SCRIPT"
		kill.TextColor3 = Color3.new(1, 1, 1)
		kill.MouseButton1Click:Connect(function()
			scriptRunning = false
			sg:Destroy()
			ContextActionService:UnbindAction("J_Action")
			ContextActionService:UnbindAction("R_Action")
			ContextActionService:UnbindAction("Q_Action")
			ContextActionService:UnbindAction("M_Action")
		end)

		local function createSetting(parent, name, key, yPos)
			local frame = Instance.new("Frame", parent)
			frame.Size = UDim2.new(0, 200, 0, 40)
			frame.Position = UDim2.new(0, 0, 0, yPos)
			frame.BackgroundTransparency = 1

			local label = Instance.new("TextLabel", frame)
			label.Size = UDim2.new(.5, 0, 1, 0)
			label.Text = name
			label.TextColor3 = Color3.new(1,1,1)
			label.BackgroundTransparency = 1

			local box = Instance.new("TextBox", frame)
			box.Size = UDim2.new(0.5, 0, 1, 0)
			box.Position = UDim2.new(0.5, 0, 0, 0)
			box.Text = tostring(SETTINGS[key])
			box.TextColor3 = Color3.new(1,1,1)
			box.BackgroundColor3 = Color3.new(0,0,0)

			box.FocusLost:Connect(function()
				local val = tonumber(box.Text)
				if val then
					SETTINGS[key] = val
				else
					box.Text = tostring(SETTINGS[key])
				end
			end)
		end

		local isrolling_kaze = false

		local controls = Instance.new("Frame", sg)
		controls.Size = UDim2.new(0.3, 0, 0.6, 0)
		controls.Position = UDim2.new(0.6, 0, 0.3, 0)
		controls.BackgroundTransparency = 1
		controls.Visible = false

		local inText = Instance.new("TextLabel", controls)
		inText.Size = UDim2.new(1,0,.8,0)
		inText.BackgroundTransparency = 1
		inText.TextColor3 = Color3.new(255,255,255)
		inText.Text = "Q - Dash\n R - Change Forms\n J - Ultimate Dash"
		inText.TextScaled = true

		inTexta.Parent = controls
		inTexta.Position = UDim2.new(0,0,.8,0)
		inTexta.Size = UDim2.new(1,0,.2,0)
		inTexta.BackgroundTransparency = 1
		inTexta.TextColor3 = Color3.new(255,255,255)
		inTexta.Text = "Current form : " .. currentForm .. ""
		inTexta.TextScaled = true

		local settingsFrame = Instance.new("Frame", sg)
		settingsFrame.Size = UDim2.new(0, 200, 0, 160)
		settingsFrame.Position = UDim2.new(0, 20, 0.2, 0)
		settingsFrame.BackgroundColor3 = Color3.new(0,0,0)
		settingsFrame.Visible = false

		createSetting(settingsFrame, "Dash Distance", "DASH_DISTANCE", 0)
		createSetting(settingsFrame, "Dash Time", "DASH_TIME", 40)
		createSetting(settingsFrame, "Ultimate Dash Distance", "ULT_DASH_DISTANCE", 80)
		createSetting(settingsFrame, "Ultimate Dash Time", "DASH_TIME_ULT", 120)

		local kazebutton = Instance.new("ImageButton")
		kazebutton.Size = UDim2.new(0, 40, 0, 40)
		kazebutton.ScaleType = Enum.ScaleType.Fit
		kazebutton.Image = "rbxassetid://131056211291675"
		kazebutton.Position = UDim2.new(0.6, 0, 0.3, -40)

		local isMoving = false
		kazebutton.MouseButton1Down:Connect(function()
			isMoving = true
		end)
		task.spawn(function()
			while scriptRunning do
				if isMoving then
					--move to mouse position
					kazebutton.Position = UDim2.new(0, player:GetMouse().X, 0, player:GetMouse().Y)
				end	
				task.wait(0.01)
			end
		end)
		kazebutton.MouseButton1Up:Connect(function()
			isMoving = false
		end)
		kazebutton.Parent = sg

		local function kazsetrolling()
			if not isrolling_kaze then
				isrolling_kaze = true
				controls.Visible = true
				settingsFrame.Visible = true
			else
				isrolling_kaze = false
				controls.Visible = false
				settingsFrame.Visible = false
			end
		end

		kazebutton.MouseButton1Click:Connect(kazsetrolling)
	end
	setupUI()

	-- Q : Dash
	local function handleQ(name, state)
		print("test")
		if state ~= Enum.UserInputState.Begin or isBusy or not scriptRunning then return end

		if currentForm ~= forms[1] then return end

		local vVelocity = SETTINGS.DASH_DISTANCE

		local soundid = "rbxassetid://91648535156370"
		local sound = Instance.new("Sound")
		sound.SoundId = soundid
		sound.Volume = 5

		sound.Parent = player.Character:FindFirstChild("HumanoidRootPart")
		sound:Play()


		isBusy = true
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then isBusy = false return end

		vVelocity += SETTINGS.DASH_DISTANCE * 2

		local lastMove = hrp.CFrame.LookVector

		local direction = (lastMove.Magnitude > 0 and lastMove or hrp.CFrame.LookVector)

		local nextPos = hrp.Position + (direction * vVelocity)

		local groundedCF = getGroundedCF(nextPos, direction)

		hrp.CFrame = groundedCF

		camera.FieldOfView /= 1.2

		task.wait(SETTINGS.DASH_TIME)

		camera.FieldOfView *= 1.2

		isBusy = false
	end

	-- R : Change Forms
	local function handleR(name, state)
		if state ~= Enum.UserInputState.End or not scriptRunning then return end

		local soundid = "rbxassetid://9085319375"
		local sound = Instance.new("Sound")
		sound.SoundId = soundid
		sound.Parent = player.Character:FindFirstChild("HumanoidRootPart")
		sound:Play()


		local index = table.find(forms, currentForm)
		if index then
			index = index + 1
			if index > #forms then index = 1 end
			currentForm = forms[index]
			inTexta.Text = "Current form : " .. currentForm .. ""
		end
	end

	-- J : Ultimate Dash
	local function handleJ(name, state)
		if state ~= Enum.UserInputState.End or not scriptRunning then return end

		if currentForm ~= forms[2] then return end

		local soundid = "rbxassetid://88702544975409"
		local sound = Instance.new("Sound")
		sound.SoundId = soundid
		sound.Parent = player.Character:FindFirstChild("HumanoidRootPart")
		sound:Play()
		Debris:AddItem(sound, 0.3)

		isBusy = true
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then isBusy = false return end

		local move = hrp.CFrame.LookVector
		local targetPos = hrp.Position + move * SETTINGS.ULT_DASH_DISTANCE
		local targetCFrame = CFrame.new(targetPos, targetPos + move)

		-- move the player a bit up because velocity is terrible on ground
		hrp.CFrame = targetCFrame * CFrame.new(0, 1, 0)
		local velocity = Instance.new("BodyVelocity")

		velocity.MaxForce = Vector3.new(10000, 10000, 10000)

		velocity.Velocity = move * 300

		velocity.Parent = hrp
		task.wait(SETTINGS.DASH_TIME_ULT / 2)
		velocity.Velocity = move * 75
		task.wait(SETTINGS.DASH_TIME_ULT / 2)
		velocity:Destroy()
		isBusy = false
	end

	-- M : Toggle GUI
	local function handleM(name, state)
		if state ~= Enum.UserInputState.End then return end
		gui.Enabled = not gui.Enabled
	end

	-- ======================= MOBILE BINDS =======================
	local function bind(actionName, func, key, title, pos)
		ContextActionService:BindAction(actionName, func, true, key)
		ContextActionService:SetTitle(actionName, title)
		ContextActionService:SetPosition(actionName, pos)
	end

	-- on death
	local function onDeath()
		local soundId = "rbxassetid://131056211291675"
		local sound = Instance.new("Sound")
		sound.SoundId = soundId
		sound.Parent = hrp
		sound:Play()
		task.wait(1)
		scriptRunning = false
	end

	bind("Q_Action", handleQ, Enum.KeyCode.Q, "Dash", UDim2.new(1, -100, 0, 100))
	bind("R_Action", handleR, Enum.KeyCode.R, "Change Forms (R)", UDim2.new(1, -110, 0, 300))
	bind("J_Action", handleJ, Enum.KeyCode.J, "Ultimate Dash", UDim2.new(1, -130, 0, 200))
	bind("M_Action", handleM, Enum.KeyCode.M, "Toggle GUI", UDim2.new(1, -130, 0, -255))
end

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanel"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 500)
frame.Position = UDim2.new(0.5, -175, 0.5, -210)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local predictorEnabled = false
local PREDICTION_TIME = 0.1 -- seconds ahead to predict

-- Iridescent Gradient Background
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 255)), -- Magenta
	ColorSequenceKeypoint.new(0.20, Color3.fromRGB(0, 255, 255)), -- Cyan
	ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 255, 0)),   -- Green
	ColorSequenceKeypoint.new(0.60, Color3.fromRGB(255, 255, 0)), -- Yellow
	ColorSequenceKeypoint.new(0.80, Color3.fromRGB(255, 0, 0)),   -- Red
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 255)), -- Magenta
}
gradient.Rotation = 45
gradient.Parent = frame

local title = Instance.new("TextLabel")
title.Text = "Kristalina Hub"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 28
title.Parent = frame

-- FPS and Ping Indicators
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = "FPSLabel"
fpsLabel.Text = "FPS: --"
fpsLabel.Size = UDim2.new(0, 90, 0, 22)
fpsLabel.Position = UDim2.new(1, -95, 0, 8)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
fpsLabel.Font = Enum.Font.SourceSansBold
fpsLabel.TextSize = 18
fpsLabel.TextXAlignment = Enum.TextXAlignment.Right
fpsLabel.Parent = frame

local pingLabel = Instance.new("TextLabel")
pingLabel.Name = "PingLabel"
pingLabel.Text = "Ping: -- ms"
pingLabel.Size = UDim2.new(0, 90, 0, 22)
pingLabel.Position = UDim2.new(1, -95, 0, 30)
pingLabel.BackgroundTransparency = 1
pingLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
pingLabel.Font = Enum.Font.SourceSansBold
pingLabel.TextSize = 18
pingLabel.TextXAlignment = Enum.TextXAlignment.Right
pingLabel.Parent = frame

-- Exit Button
local exitBtn = Instance.new("TextButton")
exitBtn.Text = "X"
exitBtn.Size = UDim2.new(0, 40, 0, 40)
exitBtn.Position = UDim2.new(0, 45, 0, 0)
exitBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
exitBtn.TextColor3 = Color3.fromRGB(255,255,255)
exitBtn.Font = Enum.Font.SourceSansBold
exitBtn.TextSize = 28
exitBtn.Parent = frame

exitBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Roll Up Button
local rollUpBtn = Instance.new("TextButton")
rollUpBtn.Text = "▲"
rollUpBtn.Size = UDim2.new(0, 40, 0, 40)
rollUpBtn.Position = UDim2.new(0, 0, 0, 0)
rollUpBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 120)
rollUpBtn.TextColor3 = Color3.fromRGB(255,255,255)
rollUpBtn.Font = Enum.Font.SourceSansBold
rollUpBtn.TextSize = 28
rollUpBtn.Parent = frame

local isRolledUp = false
local originalFrameSize = frame.Size
local originalFramePosition = frame.Position

function setRolledUp(state)
	isRolledUp = state
	if state then
		frame.Size = UDim2.new(originalFrameSize.X.Scale, originalFrameSize.X.Offset, 0, 40)
		for k, v in frame:GetChildren() do
			if v ~= title and v ~= rollUpBtn and v ~= exitBtn then
				if v:IsA("GuiObject") then
					v.Visible = false
				end
			else
				if v:IsA("GuiObject") then
					v.Visible = true
				end
			end
		end
		rollUpBtn.Text = "▼"
	else
		frame.Size = originalFrameSize
		for k, v in frame:GetChildren() do
			if v:IsA("GuiObject") then
				v.Visible = true
			end
		end
		rollUpBtn.Text = "▲"
	end
end

rollUpBtn.MouseButton1Click:Connect(function()
	setRolledUp(not isRolledUp)
end)

-- WalkSpeed Slider
local walkSpeedLabel = Instance.new("TextLabel")
walkSpeedLabel.Text = "WalkSpeed"
walkSpeedLabel.Size = UDim2.new(0, 120, 0, 30)
walkSpeedLabel.Position = UDim2.new(0, 10, 0, 50)
walkSpeedLabel.BackgroundTransparency = 1
walkSpeedLabel.TextColor3 = Color3.fromRGB(255,255,255)
walkSpeedLabel.Font = Enum.Font.SourceSans
walkSpeedLabel.TextSize = 20
walkSpeedLabel.Parent = frame

local walkSpeedSlider = Instance.new("TextButton")
walkSpeedSlider.Size = UDim2.new(0, 200, 0, 20)
walkSpeedSlider.Position = UDim2.new(0, 130, 0, 60)
walkSpeedSlider.BackgroundColor3 = Color3.fromRGB(80,80,80)
walkSpeedSlider.Text = ""
walkSpeedSlider.Parent = frame

local walkSpeedKnob = Instance.new("Frame")
walkSpeedKnob.Size = UDim2.new(0, 10, 0, 20)
walkSpeedKnob.Position = UDim2.new(0, 90, 0, 0)
walkSpeedKnob.BackgroundColor3 = Color3.fromRGB(200,200,200)
walkSpeedKnob.Parent = walkSpeedSlider

local walkSpeedValueLabel = Instance.new("TextLabel")
walkSpeedValueLabel.Text = "16"
walkSpeedValueLabel.Size = UDim2.new(0, 40, 0, 20)
walkSpeedValueLabel.Position = UDim2.new(0, 340, 0, 60)
walkSpeedValueLabel.BackgroundTransparency = 1
walkSpeedValueLabel.TextColor3 = Color3.fromRGB(255,255,255)
walkSpeedValueLabel.Font = Enum.Font.SourceSans
walkSpeedValueLabel.TextSize = 18
walkSpeedValueLabel.Parent = frame

-- WalkSpeed TextBox for direct input
local walkSpeedTextBox = Instance.new("TextBox")
walkSpeedTextBox.Size = UDim2.new(0, 40, 0, 20)
walkSpeedTextBox.Position = UDim2.new(0, 385, 0, 60)
walkSpeedTextBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
walkSpeedTextBox.TextColor3 = Color3.fromRGB(255,255,255)
walkSpeedTextBox.Font = Enum.Font.SourceSans
walkSpeedTextBox.TextSize = 18
walkSpeedTextBox.Text = ""
walkSpeedTextBox.PlaceholderText = "Set"
walkSpeedTextBox.Parent = frame

-- Fly Toggle
local flyToggle = Instance.new("TextButton")
flyToggle.Text = "Fly: OFF"
flyToggle.Size = UDim2.new(0, 95, 0, 40)
flyToggle.Position = UDim2.new(0, 75, 0, 100)
flyToggle.BackgroundColor3 = Color3.fromRGB(80,80,80)
flyToggle.TextColor3 = Color3.fromRGB(255,255,255)
flyToggle.Font = Enum.Font.SourceSansBold
flyToggle.TextSize = 22
flyToggle.Parent = frame

-- Noclip Toggle
local noclipToggle = Instance.new("TextButton")
noclipToggle.Text = "Noclip: OFF"
noclipToggle.Size = UDim2.new(0, 95, 0, 40)
noclipToggle.Position = UDim2.new(0, 180, 0, 100)
noclipToggle.BackgroundColor3 = Color3.fromRGB(80,80,80)
noclipToggle.TextColor3 = Color3.fromRGB(255,255,255)
noclipToggle.Font = Enum.Font.SourceSansBold
noclipToggle.TextSize = 22
noclipToggle.Parent = frame

-- Fly Speed Slider
local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Text = "Fly Speed"
flySpeedLabel.Size = UDim2.new(0, 130, 0, 30)
flySpeedLabel.Position = UDim2.new(0, 10, 0, 150)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.TextColor3 = Color3.fromRGB(255,255,255)
flySpeedLabel.Font = Enum.Font.SourceSans
flySpeedLabel.TextSize = 20
flySpeedLabel.Parent = frame

local flySpeedSlider = Instance.new("TextButton")
flySpeedSlider.Size = UDim2.new(0, 200, 0, 20)
flySpeedSlider.Position = UDim2.new(0, 130, 0, 160)
flySpeedSlider.BackgroundColor3 = Color3.fromRGB(80,80,80)
flySpeedSlider.Text = ""
flySpeedSlider.Parent = frame

local flySpeedKnob = Instance.new("Frame")
flySpeedKnob.Size = UDim2.new(0, 10, 0, 20)
flySpeedKnob.Position = UDim2.new(0, 90, 0, 0)
flySpeedKnob.BackgroundColor3 = Color3.fromRGB(200,200,200)
flySpeedKnob.Parent = flySpeedSlider

local flySpeedValueLabel = Instance.new("TextLabel")
flySpeedValueLabel.Text = "50"
flySpeedValueLabel.Size = UDim2.new(0, 40, 0, 20)
flySpeedValueLabel.Position = UDim2.new(0, 340, 0, 160)
flySpeedValueLabel.BackgroundTransparency = 1
flySpeedValueLabel.TextColor3 = Color3.fromRGB(255,255,255)
flySpeedValueLabel.Font = Enum.Font.SourceSans
flySpeedValueLabel.TextSize = 18
flySpeedValueLabel.Parent = frame

-- Fly/Noclip Speed TextBox for direct input
local flySpeedTextBox = Instance.new("TextBox")
flySpeedTextBox.Size = UDim2.new(0, 40, 0, 20)
flySpeedTextBox.Position = UDim2.new(0, 385, 0, 160)
flySpeedTextBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
flySpeedTextBox.TextColor3 = Color3.fromRGB(255,255,255)
flySpeedTextBox.Font = Enum.Font.SourceSans
flySpeedTextBox.TextSize = 18
flySpeedTextBox.Text = ""
flySpeedTextBox.PlaceholderText = "Set"
flySpeedTextBox.Parent = frame

-- Fling Players Button
local flingBtn = Instance.new("TextButton")
flingBtn.Text = "Fling Players"
flingBtn.Size = UDim2.new(0, 150, 0, 35)
flingBtn.Position = UDim2.new(0, 10, 0, 200)
flingBtn.BackgroundColor3 = Color3.fromRGB(80,120,80)
flingBtn.TextColor3 = Color3.fromRGB(255,255,255)
flingBtn.Font = Enum.Font.SourceSansBold
flingBtn.TextSize = 20
flingBtn.Parent = frame

-- Teleportation Button
local teleportBtn = Instance.new("TextButton")
teleportBtn.Text = "Teleport"
teleportBtn.Size = UDim2.new(0, 150, 0, 35)
teleportBtn.Position = UDim2.new(0, 180, 0, 200)
teleportBtn.BackgroundColor3 = Color3.fromRGB(80,80,120)
teleportBtn.TextColor3 = Color3.fromRGB(255,255,255)
teleportBtn.Font = Enum.Font.SourceSansBold
teleportBtn.TextSize = 20
teleportBtn.Parent = frame

-- ESP Toggle
local espToggle = Instance.new("TextButton")
espToggle.Text = "Players ESP: OFF"
espToggle.Size = UDim2.new(0, 150, 0, 35)
espToggle.Position = UDim2.new(0, 10, 0, 245)
espToggle.BackgroundColor3 = Color3.fromRGB(80,80,120)
espToggle.TextColor3 = Color3.fromRGB(255,255,255)
espToggle.Font = Enum.Font.SourceSansBold
espToggle.TextSize = 20
espToggle.Parent = frame

-- Godmode Toggle
local godmodeToggle = Instance.new("TextButton")
godmodeToggle.Text = "Godmode: OFF"
godmodeToggle.Size = UDim2.new(0, 150, 0, 35)
godmodeToggle.Position = UDim2.new(0, 180, 0, 245)
godmodeToggle.BackgroundColor3 = Color3.fromRGB(120,80,80)
godmodeToggle.TextColor3 = Color3.fromRGB(255,255,255)
godmodeToggle.Font = Enum.Font.SourceSansBold
godmodeToggle.TextSize = 20
godmodeToggle.Parent = frame

-- Invisible Toggle
local invisibleToggle = Instance.new("TextButton")
invisibleToggle.Text = "Invisible: OFF"
invisibleToggle.Size = UDim2.new(0, 150, 0, 35)
invisibleToggle.Position = UDim2.new(0, 10, 0, 290)
invisibleToggle.BackgroundColor3 = Color3.fromRGB(80,80,120)
invisibleToggle.TextColor3 = Color3.fromRGB(255,255,255)
invisibleToggle.Font = Enum.Font.SourceSansBold
invisibleToggle.TextSize = 20
invisibleToggle.Parent = frame

-- Tracer ESP Toggle
local tracerToggle = Instance.new("TextButton")
tracerToggle.Text = "Tracers: OFF"
tracerToggle.Size = UDim2.new(0, 150, 0, 35)
tracerToggle.Position = UDim2.new(0, 180, 0, 290)
tracerToggle.BackgroundColor3 = Color3.fromRGB(80,80,120)
tracerToggle.TextColor3 = Color3.fromRGB(255,255,255)
tracerToggle.Font = Enum.Font.SourceSansBold
tracerToggle.TextSize = 20
tracerToggle.Parent = frame

-- Predictor Toggle
local predictorToggle = Instance.new("TextButton")
predictorToggle.Text = "Predictor: OFF"
predictorToggle.Size = UDim2.new(0, 150, 0, 35)
predictorToggle.Position = UDim2.new(0, 10, 0, 335)
predictorToggle.BackgroundColor3 = Color3.fromRGB(80,80,120)
predictorToggle.TextColor3 = Color3.fromRGB(255,255,255)
predictorToggle.Font = Enum.Font.SourceSansBold
predictorToggle.TextSize = 20
predictorToggle.Parent = frame

-- Activate Script
local naoScript = Instance.new("TextButton")
naoScript.Text = "Naoya Script"
naoScript.Size = UDim2.new(0, 150, 0, 35)
naoScript.Position = UDim2.new(0, 180, 0, 335)
naoScript.BackgroundColor3 = Color3.fromRGB(80,80,120)
naoScript.TextColor3 = Color3.fromRGB(255,255,255)
naoScript.Font = Enum.Font.SourceSansBold
naoScript.TextSize = 20
naoScript.Parent = frame

-- Activate Script
local kazScript = Instance.new("TextButton")
kazScript.Text = "Kaze Script"
kazScript.Size = UDim2.new(0, 150, 0, 35)
kazScript.Position = UDim2.new(0, 10, 0, 380)
kazScript.BackgroundColor3 = Color3.fromRGB(80,80,120)
kazScript.TextColor3 = Color3.fromRGB(255,255,255)
kazScript.Font = Enum.Font.SourceSansBold
kazScript.TextSize = 20
kazScript.Parent = frame

-- Predictor Toggle
local aimbotToggle = Instance.new("TextButton")
aimbotToggle.Text = "Aimbot: OFF"
aimbotToggle.Size = UDim2.new(0, 150, 0, 35)
aimbotToggle.Position = UDim2.new(0, 180, 0, 380)
aimbotToggle.BackgroundColor3 = Color3.fromRGB(80,80,120)
aimbotToggle.TextColor3 = Color3.fromRGB(255,255,255)
aimbotToggle.Font = Enum.Font.SourceSansBold
aimbotToggle.TextSize = 20
aimbotToggle.Parent = frame

-- Subplace Finder
local subplaceFinder = Instance.new("TextButton")
subplaceFinder.Text = "Subplace Finder"
subplaceFinder.Size = UDim2.new(0, 150, 0, 35)
subplaceFinder.Position = UDim2.new(0, 10, 0, 425)
subplaceFinder.BackgroundColor3 = Color3.fromRGB(80,80,120)
subplaceFinder.TextColor3 = Color3.fromRGB(255,255,255)
subplaceFinder.Font = Enum.Font.SourceSansBold
subplaceFinder.TextSize = 20
subplaceFinder.Parent = frame

-- Checkpoints
local checkpoints = Instance.new("TextButton")
checkpoints.Text = "Checkpoints"
checkpoints.Size = UDim2.new(0, 150, 0, 35)
checkpoints.Position = UDim2.new(0, 180, 0, 425)
checkpoints.BackgroundColor3 = Color3.fromRGB(80,80,120)
checkpoints.TextColor3 = Color3.fromRGB(255,255,255)
checkpoints.Font = Enum.Font.SourceSansBold
checkpoints.TextSize = 20
checkpoints.Parent = frame

-- Hide Gui
local hideGui = Instance.new("TextButton")
hideGui.Text = "Toggle HGui: ON"
hideGui.Size = UDim2.new(0, 100, 0, 25)
hideGui.Position = UDim2.new(1, -100, 1, -25)
hideGui.BackgroundColor3  =  Color3.fromRGB(0, 120,120)
hideGui.TextColor3 = Color3.fromRGB(255,255,255)
hideGui.Font = Enum.Font.SourceSansBold
hideGui.TextSize = 20
hideGui.Parent = frame

local signature = Instance.new("TextLabel")
signature.Text = "KristaliK"
signature.TextScaled = true
signature.RichText = true
signature.Size = UDim2.new(1, 0, 0, 20)
signature.Position = UDim2.new(0, 0, 1, -25)
signature.BackgroundTransparency = 1
signature.TextColor3 = Color3.fromRGB(255,255,255)
signature.Parent = frame 
signature.Font = Enum.Font.FredokaOne

screenGui.Parent = player.PlayerGui

-- Logic
local guiEnabled = false

local draggingWalk = false
local draggingFly = false
local minWalkSpeed, maxWalkSpeed = 8, 100
local minFlySpeed, maxFlySpeed = 20, 200
local currentWalkSpeed = 16
local currentFlySpeed = 50
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local godmodeEnabled = false
local invisibleEnabled = false
local flyConnection = nil
local noclipConnection = nil
local godmodeConnection = nil
local espConnections = {}
local tracerEnabled = false
local tracerConnection = nil
local tracerLines = {}

function setWalkSpeed(val)
	currentWalkSpeed = val
	walkSpeedValueLabel.Text = tostring(val)
	walkSpeedTextBox.Text = ""
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = val
	end
	updateSliderKnob(walkSpeedSlider, walkSpeedKnob, minWalkSpeed, maxWalkSpeed, val)
end

function setFlySpeed(val)
	currentFlySpeed = val
	flySpeedValueLabel.Text = tostring(val)
	flySpeedTextBox.Text = ""
	updateSliderKnob(flySpeedSlider, flySpeedKnob, minFlySpeed, maxFlySpeed, val)
end

function updateSliderKnob(slider, knob, minVal, maxVal, curVal)
	local percent = (curVal - minVal) / (maxVal - minVal)
	knob.Position = UDim2.new(0, math.floor(percent * (slider.AbsoluteSize.X - knob.AbsoluteSize.X)), 0, 0)
end

walkSpeedSlider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingWalk = true
	end
end)
walkSpeedSlider.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingWalk = false
	end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
	if draggingWalk and input.UserInputType == Enum.UserInputType.MouseMovement then
		local x = input.Position.X - walkSpeedSlider.AbsolutePosition.X
		local percent = math.clamp(x / walkSpeedSlider.AbsoluteSize.X, 0, 1)
		local val = math.floor(minWalkSpeed + percent * (maxWalkSpeed - minWalkSpeed))
		setWalkSpeed(val)
	end
	if draggingFly and input.UserInputType == Enum.UserInputType.MouseMovement then
		local x = input.Position.X - flySpeedSlider.AbsolutePosition.X
		local percent = math.clamp(x / flySpeedSlider.AbsoluteSize.X, 0, 1)
		local val = math.floor(minFlySpeed + percent * (maxFlySpeed - minFlySpeed))
		setFlySpeed(val)
	end
end)

naoScript.MouseButton1Click:Connect(naoyascript)
kazScript.MouseButton1Click:Connect(kazescript)

flySpeedSlider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingFly = true
	end
end)
flySpeedSlider.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingFly = false
	end
end)

updateSliderKnob(walkSpeedSlider, walkSpeedKnob, minWalkSpeed, maxWalkSpeed, currentWalkSpeed)
updateSliderKnob(flySpeedSlider, flySpeedKnob, minFlySpeed, maxFlySpeed, currentFlySpeed)


hideGui.MouseButton1Down:Connect(function()
	guiEnabled = not guiEnabled
	local healthgui = playerGui:FindFirstChild("KRSTALINASHealthGui")
	if healthgui then
		healthgui.Enabled = not guiEnabled
	end
	
	if guiEnabled then
		hideGui.Text = "Toggle HGui: ON"
		hideGui.BackgroundColor3 = Color3.fromRGB(0, 120,120)
	else
		hideGui.Text = "Toggle HGui: OFF"
		hideGui.BackgroundColor3 = Color3.fromRGB(80,80,120)
	end
end)
-- WalkSpeed TextBox logic
walkSpeedTextBox.FocusLost:Connect(function(enterPressed)
	local text = walkSpeedTextBox.Text
	local num = tonumber(text)
	if num and num >= minWalkSpeed and num <= maxWalkSpeed then
		setWalkSpeed(math.floor(num))
	else
		walkSpeedTextBox.Text = ""
	end
end)

-- Fly/Noclip Speed TextBox logic
flySpeedTextBox.FocusLost:Connect(function(enterPressed)
	local text = flySpeedTextBox.Text
	local num = tonumber(text)
	if num and num >= minFlySpeed and num <= maxFlySpeed then
		setFlySpeed(math.floor(num))
	else
		flySpeedTextBox.Text = ""
	end
end)

local flyDirectionY = 0

function flyUp(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		flyDirectionY = 1
	else
		flyDirectionY = 0
	end
end

function flyDown(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		flyDirectionY = -1
	else
		flyDirectionY = 0
	end
end

-- Fly logic
function enableFly()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local bodyVel = Instance.new("BodyVelocity")
	bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bodyVel.Velocity = Vector3.new(0,0,0)
	bodyVel.Parent = humanoidRootPart
	

	ContextActionService:BindAction("FlyDown", flyDown, true)
	ContextActionService:BindAction("FlyUp", flyUp, true)
	ContextActionService:SetTitle("FlyUp", "⬆️")
	ContextActionService:SetTitle("FlyDown", "⬇️")
	ContextActionService:SetPosition("FlyUp", UDim2.new(.8, 0, .35, 0))
	ContextActionService:SetPosition("FlyDown", UDim2.new(.8, 0, .65, 0))

	flyConnection = game:GetService("RunService").RenderStepped:Connect(function()
		local moveVec = Vector3.new(0,0,0)
		
		--TODO: Make mobile friendly
		
		--MOBILE CONTROLS
		if game:GetService("UserInputService"):GetLastInputType() == Enum.UserInputType.Touch then
			local move = humanoid.MoveDirection
			
			local total = Vector3.new(move.X, flyDirectionY, move.Z)
			if total.Magnitude > 0 then
				moveVec = total.Unit
			else
				moveVec = Vector3.new(0, 0, 0)
			end
		end
		
		if game:GetService("UserInputService").KeyboardEnabled then
				--KEYBOARD CONTROLS
				if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
					moveVec = moveVec + workspace.CurrentCamera.CFrame.LookVector
				end
				if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
					moveVec = moveVec - workspace.CurrentCamera.CFrame.LookVector
				end
				if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
					moveVec = moveVec - workspace.CurrentCamera.CFrame.RightVector
				end
				if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
					moveVec = moveVec + workspace.CurrentCamera.CFrame.RightVector
				end
				if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
					moveVec = moveVec + Vector3.new(0,1,0)
				end
				if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then
					moveVec = moveVec - Vector3.new(0,1,0)
				end
		end
		
		if moveVec.Magnitude > 0 then
			bodyVel.Velocity = moveVec.Unit * currentFlySpeed
		else
			bodyVel.Velocity = Vector3.new(0,0,0)
		end
	end)
end

function disableFly()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	for k, v in humanoidRootPart:GetChildren() do
		if v:IsA("BodyVelocity") then
			v:Destroy()
		end
	end

	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end
	ContextActionService:UnbindAction("FlyUp")
	ContextActionService:UnbindAction("FlyDown")	
end

flyToggle.MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	if flyEnabled then
		flyToggle.Text = "Fly: ON"
		enableFly()
	else
		flyToggle.Text = "Fly: OFF"
		disableFly()
	end
end)

-- Noclip logic
function enableNoclip()
	noclipEnabled = true
	noclipToggle.Text = "Noclip: ON"
	local function noclipFunc()
		local character = player.Character
		if character then
			for k, v in character:GetDescendants() do
				if v:IsA("BasePart") then
					v.CanCollide = false
				end
			end
		end
	end
	noclipConnection = game:GetService("RunService").Stepped:Connect(noclipFunc)
end

function disableNoclip()
	noclipEnabled = false
	noclipToggle.Text = "Noclip: OFF"
	if noclipConnection then
		noclipConnection:Disconnect()
		noclipConnection = nil
	end
	local character = player.Character
	if character then
		for k, v in character:GetDescendants() do
			if v:IsA("BasePart") then
				v.CanCollide = true
			end
		end
	end
end

noclipToggle.MouseButton1Click:Connect(function()
	if not noclipEnabled then
		enableNoclip()
	else
		disableNoclip()
	end
end)

-- Update fly speed live
game:GetService("RunService").RenderStepped:Connect(function()
	if flyEnabled then
		local character = player.Character
		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				for k, v in humanoidRootPart:GetChildren() do
					if v:IsA("BodyVelocity") then
						v.MaxForce = Vector3.new(1e5, 1e5, 1e5)
					end
				end
			end
		end
	end
end)

local function flingpl()
	local av = Instance.new("BodyAngularVelocity")
	av.AngularVelocity = Vector3.new(0, 155, 0)
	av.P = 150
	av.Parent = hrp
	av.MaxTorque = Vector3.new(10000000, 10000000, 10000000)
	return av
end

local flingb = false

-- Fling Players logic
flingBtn.MouseButton1Click:Connect(function()
	flingb = not flingb
	-- spin the player 
	local vel = flingpl()

	if not flingb then
		vel:Destroy()
	end
end)

-- Teleportation logic
local teleportGui = Instance.new("Frame")
teleportGui.Size = UDim2.new(0, 220, 0, 180)
teleportGui.Position = UDim2.new(0.5, -110, 0.5, -90)
teleportGui.BackgroundColor3 = Color3.fromRGB(30,30,60)
teleportGui.Visible = false
teleportGui.Parent = screenGui
teleportGui.Active = true
teleportGui.Draggable = true

local teleportTitle = Instance.new("TextLabel")
teleportTitle.Text = "Teleport to Player"
teleportTitle.Size = UDim2.new(1, 0, 0, 30)
teleportTitle.BackgroundTransparency = 1
teleportTitle.TextColor3 = Color3.fromRGB(255,255,255)
teleportTitle.Font = Enum.Font.SourceSansBold
teleportTitle.TextSize = 22
teleportTitle.Parent = teleportGui

local closeTeleportBtn = Instance.new("TextButton")
closeTeleportBtn.Text = "X"
closeTeleportBtn.Size = UDim2.new(0, 30, 0, 30)
closeTeleportBtn.Position = UDim2.new(1, -35, 0, 0)
closeTeleportBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
closeTeleportBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeTeleportBtn.Font = Enum.Font.SourceSansBold
closeTeleportBtn.TextSize = 22
closeTeleportBtn.Parent = teleportGui

closeTeleportBtn.MouseButton1Click:Connect(function()
	teleportGui.Visible = false
end)

local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, -20, 1, -40)
playerList.Position = UDim2.new(0, 10, 0, 35)
playerList.BackgroundTransparency = 1
playerList.CanvasSize = UDim2.new(0,0,0,0)
playerList.ScrollBarThickness = 6
playerList.Parent = teleportGui

function refreshPlayerList()
	for k, v in playerList:GetChildren() do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end
	local y = 0
	for k, otherPlayer in game.Players:GetPlayers() do
		if otherPlayer ~= player then
			local btn = Instance.new("TextButton")
			btn.Text = otherPlayer.Name
			btn.Size = UDim2.new(1, 0, 0, 30)
			btn.Position = UDim2.new(0, 0, 0, y)
			btn.BackgroundColor3 = Color3.fromRGB(60,60,120)
			btn.TextColor3 = Color3.fromRGB(255,255,255)
			btn.Font = Enum.Font.SourceSans
			btn.TextSize = 18
			btn.Parent = playerList
			y = y + 35
			btn.MouseButton1Click:Connect(function()
				local myChar = player.Character
				local targetChar = otherPlayer.Character
				if myChar and targetChar then
					local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
					local myRoot = myChar:FindFirstChild("HumanoidRootPart")
					if targetRoot and myRoot then
						myChar:PivotTo(targetRoot.CFrame + Vector3.new(0,3,0))
					end
				end
				teleportGui.Visible = false
			end)
		end
	end
	playerList.CanvasSize = UDim2.new(0,0,0,y)
end

teleportBtn.MouseButton1Click:Connect(function()
	teleportGui.Visible = true
	refreshPlayerList()
end)

-- ESP logic
function createESPForPlayer(targetPlayer)
	local char = targetPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- Name ESP
	local nameGui = Instance.new("BillboardGui")
	nameGui.Name = "ESPName"
	nameGui.Adornee = root
	nameGui.Size = UDim2.new(0, 200, 0, 50)
	nameGui.StudsOffset = Vector3.new(0, 3, 0)
	nameGui.AlwaysOnTop = true
	nameGui.Parent = root

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = targetPlayer.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextSize = 22
	nameLabel.Parent = nameGui

	-- Box ESP
	local highlight = Instance.new("Highlight")
	highlight.Name = "ESPHighlight"
	highlight.Adornee = char
	highlight.FillColor = Color3.fromRGB(255,255,0)
	highlight.OutlineColor = Color3.fromRGB(255,255,255)
	highlight.FillTransparency = 0.7
	highlight.OutlineTransparency = 0.2
	highlight.Parent = char

	if char.Humanoid then
		char.Humanoid.Died:Connect(function()
			if espEnabled then
				nameLabel.Text = targetPlayer.Name .. " (DEAD)"
				task.wait(0.5)
				if espEnabled then
					removeESPForPlayer(targetPlayer)
				end
			end
		end)
	end

	espConnections[targetPlayer] = {
		nameGui = nameGui,
		highlight = highlight
	}
end

function removeESPForPlayer(targetPlayer)
	local char = targetPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if root then
		local nameGui = root:FindFirstChild("ESPName")
		if nameGui then nameGui:Destroy() end
	end
	local highlight = char:FindFirstChild("ESPHighlight")
	if highlight then highlight:Destroy() end
	espConnections[targetPlayer] = nil
end

function enableESP()
	espEnabled = true
	espToggle.Text = "Players ESP: ON"
	for k, otherPlayer in game.Players:GetPlayers() do
		if otherPlayer ~= player then
			createESPForPlayer(otherPlayer)
			otherPlayer.CharacterRemoving:Connect(function()
				removeESPForPlayer(otherPlayer)
			end)
			otherPlayer.CharacterAdded:Connect(function()
				task.wait(2)
				createESPForPlayer(otherPlayer)
			end)
		end
	end
end
-- auto player tracker : left and join

Players.PlayerAdded:Connect(function(plr)
	StarterGui:SetCore("SendNotification", {
		Title = plr.Name,
		Text = "Player Joined",
		Icon = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),
		Duration = 2,
		Callback = nil,
	})
end)

--[[StarterGui:SetCore("SendNotification", {
					Title = otherPlayer.Name,
					Text = "Player Respawned",
					Icon = Players:GetUserThumbnailAsync(otherPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),
					Duration = 2,
					Callback = nil,
				})]]

Players.PlayerRemoving:Connect(function(plr)
	StarterGui:SetCore("SendNotification", {
		Title = plr.Name,
		Text = "Player Left",
		Icon = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),
		Duration = 2,
		Callback = nil,
	})
end)

function disableESP()
	espEnabled = false
	espToggle.Text = "Players ESP: OFF"
	for k, otherPlayer in game.Players:GetPlayers() do
		if otherPlayer ~= player then
			removeESPForPlayer(otherPlayer)
		end
	end
end

espToggle.MouseButton1Click:Connect(function()
	if not espEnabled then
		enableESP()
	else
		disableESP()
	end
end)

game.Players.PlayerAdded:Connect(function(plr)
	if espEnabled and plr ~= player then
		plr.CharacterAdded:Connect(function()
			createESPForPlayer(plr)
		end)
	end
end)
game.Players.PlayerRemoving:Connect(function(plr)
	if espEnabled and plr ~= player then
		removeESPForPlayer(plr)
	end
end)

-- Predictor logic
local predictorData = {} -- keyed by player, stores {connection, indicator, highlight}

local function predictAttach(targetPlayer)
	local character = targetPlayer.Character
	if not character then print("no char") return end

	-- Clean up any previous data for this player
	local prev = predictorData[targetPlayer]
	if prev then
		if prev.connection then prev.connection:Disconnect() end
		if prev.indicator then prev.indicator.Parent = nil end
		if prev.highlight then prev.highlight.Parent = nil end
		predictorData[targetPlayer] = nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not hrp then
		return
	end

	-- Create the prediction indicator part
	local indicator = Instance.new("Part")
	indicator.Name = "PredictorIndicator_" .. targetPlayer.Name
	indicator.Size = Vector3.new(2, 4, 2)
	indicator.Color = Color3.new(1, 0, 0)
	indicator.Material = Enum.Material.Neon
	indicator.Anchored = true
	indicator.CanCollide = false
	indicator.Transparency = 1 -- Start hidden
	indicator.CastShadow = false
	indicator.Shape = Enum.PartType.Block
	indicator.Parent = workspace
	indicator.CanTouch = false
	indicator.CanQuery = false
	indicator.CastShadow = false

	-- Add Highlight for visibility
	local highlight = Instance.new("Highlight")
	highlight.Name = "PredictorHighlight"
	highlight.Adornee = indicator
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = Color3.new(1, 0, 0)
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Parent = indicator

	local connection
	connection = RunService.Heartbeat:Connect(function()
		-- Validate character still exists
		if not character or not character.Parent or not hrp or not hrp.Parent or not predictorEnabled then
			if connection then
				connection:Disconnect()
			end
			indicator.Parent = nil
			highlight.Parent = nil
			predictorData[targetPlayer] = nil
			return
		end

		-- Use AssemblyLinearVelocity instead of MoveDirection
		-- MoveDirection doesn't replicate for other players on the client
		local velocity = hrp.AssemblyLinearVelocity
		local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
		local verticalSpeed = math.abs(velocity.Y)

		if horizontalSpeed > 1 then
			-- Player is walking/running - predict future position
			local predictedPosition = hrp.Position + velocity * PREDICTION_TIME
			indicator.CFrame = CFrame.new(predictedPosition)
			indicator.Transparency = 0.3
			highlight.FillTransparency = 0.5
			highlight.OutlineTransparency = 0

		elseif verticalSpeed > 5 then
			-- Player is jumping or falling
			local predictedPosition = hrp.Position + velocity * PREDICTION_TIME
			indicator.CFrame = CFrame.new(predictedPosition)
			indicator.Transparency = 0.3
			highlight.FillTransparency = 0.5
			highlight.OutlineTransparency = 0

		else
			-- Standing still - hide indicator
			indicator.Transparency = 1
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
		end
	end)

	predictorData[targetPlayer] = {
		connection = connection,
		indicator = indicator,
		highlight = highlight
	}
end

local function removeIndicator(targetPlayer)
	local data = predictorData[targetPlayer]
	if data then
		if data.connection then data.connection:Disconnect() end
		if data.indicator then data.indicator.Parent = nil end
		if data.highlight then data.highlight.Parent = nil end
		predictorData[targetPlayer] = nil
	end
end

local function enablePredictor()
	predictorEnabled = true
	predictorToggle.Text = "Predictor: ON"
	predictorToggle.BackgroundColor3 = Color3.fromRGB(0,120,120)

	-- Attach to every player's character
	for _, playerr in game.Players:GetPlayers() do
		if playerr ~= player then
			predictAttach(playerr)

			playerr.CharacterRemoving:Connect(function()
				removeIndicator(playerr)
			end)

			playerr.CharacterAdded:Connect(function()
				task.wait(2)
				predictAttach(playerr)
			end)
		end
	end
end

local function disablePredictor()
	predictorEnabled = false
	predictorToggle.Text = "Predictor: OFF"
	predictorToggle.BackgroundColor3 = Color3.fromRGB(80,80,120)

	-- Clean up all indicators and connections
	for targetPlayer, data in pairs(predictorData) do
		if data.connection then data.connection:Disconnect() end
		if data.indicator then data.indicator.Parent = nil end
		if data.highlight then data.highlight.Parent = nil end
	end
	table.clear(predictorData)
end

-- Handle players joining/leaving while predictor is active
game.Players.PlayerAdded:Connect(function(plr)
	if predictorEnabled and plr ~= player then
		plr.CharacterAdded:Connect(function()
			if predictorEnabled then
				predictAttach(plr)
			end
		end)
	end
end)

game.Players.PlayerRemoving:Connect(function(plr)
	local data = predictorData[plr]
	if data then
		if data.connection then data.connection:Disconnect() end
		if data.indicator then data.indicator.Parent = nil end
		if data.highlight then data.highlight.Parent = nil end
		predictorData[plr] = nil
	end
end)

-- Tracer ESP logic
local tracerGui = Instance.new("ScreenGui")
tracerGui.Name = "TracerGui"
tracerGui.ResetOnSpawn = false
tracerGui.Parent = player.PlayerGui

local TRACER_COLOR = Color3.fromRGB(0, 255, 255)
local TRACER_THICKNESS = 2

local function createTracerForPlayer(targetPlayer)
	if targetPlayer == player then return end
	local line = Instance.new("Frame")
	line.Name = "Tracer_" .. targetPlayer.Name
	line.BackgroundColor3 = TRACER_COLOR
	line.BorderSizePixel = 0
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.Size = UDim2.new(0, 0, 0, TRACER_THICKNESS)
	line.Visible = false
	line.Parent = tracerGui
	tracerLines[targetPlayer] = line
end

local function removeTracerForPlayer(targetPlayer)
	local line = tracerLines[targetPlayer]
	if line then
		line:Destroy()
	end
	tracerLines[targetPlayer] = nil
end

local function enableTracers()
	tracerEnabled = true
	tracerToggle.Text = "Tracers: ON"
	tracerToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 120)

	for _, otherPlayer in game.Players:GetPlayers() do
		createTracerForPlayer(otherPlayer)
	end

	tracerConnection = game:GetService("RunService").RenderStepped:Connect(function()
		local camera = workspace.CurrentCamera
		local viewportSize = camera.ViewportSize
		local origin = Vector2.new(viewportSize.X / 2, viewportSize.Y)

		for targetPlayer, line in pairs(tracerLines) do
			local char = targetPlayer.Character
			if char then
				local head = char:FindFirstChild("Head")
				local root = char:FindFirstChild("HumanoidRootPart")
				local targetPart = head or root
				if targetPart then
					local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
					local screenPos2D = Vector2.new(screenPos.X, screenPos.Y)
					local distance = (screenPos2D - origin).Magnitude
					local angle = math.atan2(screenPos2D.Y - origin.Y, screenPos2D.X - origin.X)

					line.Size = UDim2.new(0, distance, 0, TRACER_THICKNESS)
					line.Position = UDim2.new(0, (origin.X + screenPos2D.X) / 2, 0, (origin.Y + screenPos2D.Y) / 2)
					line.Rotation = math.deg(angle)
					line.Visible = true
				else
					line.Visible = false
				end
			else
				line.Visible = false
			end
		end
	end)
end

local function disableTracers()
	tracerEnabled = false
	tracerToggle.Text = "Tracers: OFF"
	tracerToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 120)

	if tracerConnection then
		tracerConnection:Disconnect()
		tracerConnection = nil
	end

	for targetPlayer, line in pairs(tracerLines) do
		line:Destroy()
	end
	tracerLines = {}
end

predictorToggle.MouseButton1Click:Connect(function()
	if predictorEnabled then
		disablePredictor()
	else
		enablePredictor()
	end
end)

tracerToggle.MouseButton1Click:Connect(function()
	if tracerEnabled then
		disableTracers()
	else
		enableTracers()
	end
end)

game.Players.PlayerAdded:Connect(function(plr)
	if tracerEnabled and plr ~= player then
		plr.CharacterAdded:Connect(function()
			task.wait(0.5)
			createTracerForPlayer(plr)
		end)
	end
end)

game.Players.PlayerRemoving:Connect(function(plr)
	if tracerEnabled then
		removeTracerForPlayer(plr)
	end
end)

-- Godmode logic
function enableGodmode()
	godmodeEnabled = true
	godmodeToggle.Text = "Godmode: ON"
	local function godmodeFunc()
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.Health = humanoid.MaxHealth
				humanoid:GetPropertyChangedSignal("Health"):Connect(function()
					if godmodeEnabled and humanoid.Health < humanoid.MaxHealth then
						humanoid.Health = humanoid.MaxHealth
					end
				end)
			end
		end
	end
	godmodeConnection = game:GetService("RunService").Stepped:Connect(godmodeFunc)
end

function disableGodmode()
	godmodeEnabled = false
	godmodeToggle.Text = "Godmode: OFF"
	if godmodeConnection then
		godmodeConnection:Disconnect()
		godmodeConnection = nil
	end
end

godmodeToggle.MouseButton1Click:Connect(function()
	if not godmodeEnabled then
		enableGodmode()
	else
		disableGodmode()
	end
end)

-- Invisible logic
function enableInvisible()
	invisibleEnabled = true
	invisibleToggle.Text = "Invisible: ON"
	local character = player.Character
	if character then
		for k, v in character:GetDescendants() do
			if v:IsA("BasePart") then
				v.Transparency = 1
			end
			if v:IsA("Decal") then
				v.Transparency = 1
			end
		end
	end
end

function disableInvisible()
	invisibleEnabled = false
	invisibleToggle.Text = "Invisible: OFF"
	local character = player.Character
	if character then
		for k, v in character:GetDescendants() do
			if v:IsA("BasePart") then
				v.Transparency = 0
			end
			if v:IsA("Decal") then
				v.Transparency = 0
			end
		end
	end
end

local aimbotEnabled = false

local function enableAimbot()
	local camera = workspace.CurrentCamera
	enablePredictor()

	aimbotEnabled = true

	local function getClosestPlayer()
		local closestPlayer = nil
		local shortestDistance = math.huge
		for _, player in game.Players:GetPlayers() do
			if player ~= game.Players.LocalPlayer then
				local character = player.Character
				if character and character:FindFirstChild("HumanoidRootPart") then
					local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
					if distance < shortestDistance then
						shortestDistance = distance
						closestPlayer = player
						return distance, player
					end
				end
			end
		end
	end

	-- first person

	aimbotToggle.Text = "Aimbot: ON"

	-- target predictor, if no indicator is found, use the closest player	

	local function loop()
		print("start")
		if not aimbotEnabled then warn("aimbotdisabled") return end
		task.wait(0.05)
		local distance, cPlayer = getClosestPlayer()
		local predictor = predictorData[cPlayer]
		if not predictor then return end
		local indicator = predictor.indicator
		if cPlayer then
			local target = indicator or cPlayer.Character.HumanoidRootPart
			local humanoid = cPlayer.Character:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 and target then
				-- print("Aiming at player: " .. cPlayer.Name)
				-- go first person

				local targetPosition = target.Position
				local cameraCFrame = camera.CFrame
				local cameraLookVector = cameraCFrame.LookVector
				local cameraPosition = hrp.Position
				local direction = (targetPosition - cameraPosition).Unit
				local angle = math.acos(cameraLookVector:Dot(direction))
				local targetCFrame = CFrame.new(cameraPosition, targetPosition)

				camera.CameraType = Enum.CameraType.Scriptable
				camera.CFrame = targetCFrame
				print(targetCFrame)
				--camera.CFrame = CFrame.lookAt(cameraPosition, targetPosition)
			else
				print("target not found")
			end
		else
			warn("closest player not found")
		end
		loop()
	end

	loop()
end

local function disableAimbot()
	aimbotEnabled = false
	aimbotToggle.Text = "Aimbot: OFF"
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Custom
end

aimbotToggle.MouseButton1Click:Connect(function()
	if not aimbotEnabled then
		enableAimbot()
	else
		disableAimbot()
	end
end)

invisibleToggle.MouseButton1Click:Connect(function()
	if not invisibleEnabled then
		enableInvisible()
	else
		disableInvisible()
	end
end)

-- Set initial WalkSpeed
setWalkSpeed(currentWalkSpeed)
setFlySpeed(currentFlySpeed)

-- Reapply settings on respawn
player.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	setWalkSpeed(currentWalkSpeed)
	if flyEnabled then
		enableFly()
	end
	if noclipEnabled then
		enableNoclip()
	end
	if godmodeEnabled then
		enableGodmode()
	end
	if invisibleEnabled then
		enableInvisible()
	end
	if tracerEnabled then
		enableTracers()
	end
end)

-- Subplacer logic
local subplaceGui = Instance.new("Frame")
subplaceGui.Size = UDim2.new(0, 220, 0, 180)
subplaceGui.Position = UDim2.new(0.5, -110, 0.5, -90)
subplaceGui.BackgroundColor3 = Color3.fromRGB(30,30,60)
subplaceGui.Visible = false
subplaceGui.Parent = screenGui
subplaceGui.Active = true
subplaceGui.Draggable = true

local subplaceTitle = Instance.new("TextLabel")
subplaceTitle.Text = "Find game's subplaces"
subplaceTitle.Size = UDim2.new(1, -30, 0, 30)
subplaceTitle.BackgroundTransparency = 1
subplaceTitle.TextColor3 = Color3.fromRGB(255,255,255)
subplaceTitle.Font = Enum.Font.SourceSansBold
subplaceTitle.TextSize = 22
subplaceTitle.Parent = subplaceGui

local closeSubplaceBtn = Instance.new("TextButton")
closeSubplaceBtn.Text = "X"
closeSubplaceBtn.Size = UDim2.new(0, 30, 0, 30)
closeSubplaceBtn.Position = UDim2.new(1, -30, 0, 0)
closeSubplaceBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
closeSubplaceBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeSubplaceBtn.Font = Enum.Font.SourceSansBold
closeSubplaceBtn.TextSize = 22
closeSubplaceBtn.Parent = subplaceGui

closeSubplaceBtn.MouseButton1Click:Connect(function()
	subplaceGui.Visible = false
end)

local subplaceList = Instance.new("ScrollingFrame")
subplaceList.Size = UDim2.new(1, -20, 1, -40)
subplaceList.Position = UDim2.new(0, 10, 0, 35)
subplaceList.BackgroundTransparency = 1
subplaceList.CanvasSize = UDim2.new(0,0,0,0)
subplaceList.ScrollBarThickness = 6
subplaceList.Parent = subplaceGui

function refreshSubplaceList()
	for k, v in subplaceList:GetChildren() do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end
	local pages = game.AssetService:GetGamePlacesAsync()
	local places = {}
	while task.wait() do
		local currentPage = pages:GetCurrentPage()
		for k, v in currentPage do
			table.insert(places, v)
		end
		if pages.IsFinished then
			break
		end
		pages:AdvanceToNextPageAsync()
	end
	local y = 0
	for k, place in places do
		local btn = Instance.new("TextButton")
		btn.Text = place.Name .. " (" .. place.PlaceId .. ")"
		btn.Size = UDim2.new(1, 0, 0, 30)
		btn.Position = UDim2.new(0, 0, 0, y)
		btn.BackgroundColor3 = Color3.fromRGB(60,60,120)
		btn.TextColor3 = Color3.fromRGB(255,255,255)
		btn.Font = Enum.Font.SourceSans
		btn.TextSize = 18
		btn.Parent = subplaceList
		y = y + 35
		btn.MouseButton1Click:Connect(function()
			game:GetService("TeleportService"):Teleport(place.PlaceId)
			subplaceGui.Visible = false
		end)
	end
	subplaceList.CanvasSize = UDim2.new(0,0,0,y)
end

subplaceFinder.MouseButton1Click:Connect(function()
	subplaceGui.Visible = true
	refreshSubplaceList()
end)


-- Checkpoints logic
local checkpointsGui = Instance.new("Frame")
checkpointsGui.Size = UDim2.new(0, 220, 0, 180)
checkpointsGui.Position = UDim2.new(0.5, -110, 0.5, -90)
checkpointsGui.BackgroundColor3 = Color3.fromRGB(30,30,60)
checkpointsGui.Visible = false
checkpointsGui.Parent = screenGui
checkpointsGui.Active = true
checkpointsGui.Draggable = true

local checkpointTitle = Instance.new("TextLabel")
checkpointTitle.Text = "Create checkpoints"
checkpointTitle.Size = UDim2.new(1, -30, 0, 30)
checkpointTitle.BackgroundTransparency = 1
checkpointTitle.TextColor3 = Color3.fromRGB(255,255,255)
checkpointTitle.Font = Enum.Font.SourceSansBold
checkpointTitle.TextSize = 22
checkpointTitle.Parent = checkpointsGui

local closeCheckpointsBtn = Instance.new("TextButton")
closeCheckpointsBtn.Text = "X"
closeCheckpointsBtn.Size = UDim2.new(0, 30, 0, 30)
closeCheckpointsBtn.Position = UDim2.new(1, -30, 0, 0)
closeCheckpointsBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
closeCheckpointsBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeCheckpointsBtn.Font = Enum.Font.SourceSansBold
closeCheckpointsBtn.TextSize = 22
closeCheckpointsBtn.Parent = checkpointsGui

closeCheckpointsBtn.MouseButton1Click:Connect(function()
	checkpointsGui.Visible = false
end)

local checkpointsList = Instance.new("ScrollingFrame")
checkpointsList.Size = UDim2.new(1, -20, .8, -35)
checkpointsList.Position = UDim2.new(0, 10, 0, 35)
checkpointsList.BackgroundTransparency = 1
checkpointsList.CanvasSize = UDim2.new(0,0,0,0)
checkpointsList.ScrollBarThickness = 6
checkpointsList.Parent = checkpointsGui

local addBtn = Instance.new("TextButton")
addBtn.Text = "➕ Add"
addBtn.Size = UDim2.new(1, 0, 0, 30)
addBtn.Position = UDim2.new(0, 0, 1, -30)
addBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
addBtn.TextColor3 = Color3.fromRGB(255,255,255)
addBtn.Font = Enum.Font.SourceSansBold
addBtn.TextScaled = true
addBtn.Parent = checkpointsGui

local foldercheckpoints = Instance.new("Folder")
foldercheckpoints.Name = "CheckpointsKRS"
foldercheckpoints.Parent = workspace

addBtn.MouseButton1Click:Connect(function()
	local newCheckpoint = Instance.new("SpawnLocation")
	newCheckpoint.Size = Vector3.new(0.5, 5, 5)
	newCheckpoint.Name = "Checkpoint" .. #checkpointsT + 1
	newCheckpoint.Parent = foldercheckpoints
	newCheckpoint.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, -humanoid.HipHeight - 0.5, 0)
	newCheckpoint.Orientation = Vector3.new(0,0,-90)
	newCheckpoint.Material = Enum.Material.Neon
	newCheckpoint.BrickColor = BrickColor.new("Really red")
	newCheckpoint.Shape = Enum.PartType.Cylinder

	table.insert(checkpointsT, newCheckpoint)
	
	newCheckpoint:SetAttribute("Index", #checkpointsT)

	newCheckpoint.Anchored = true
	refreshCheckpointsList()
end)

function color3ToRGB(color3)
	return color3.R * 255, color3.G * 255, color3.B * 255
end

function refreshCheckpointsList()
	for k, v in checkpointsList:GetChildren() do
		if v:IsA("TextButton") or v:IsA("TextLabel") or v:IsA("TextBox") then
			v:Destroy()
		end
	end
	
	local y = 0
	for k, checkpoint in checkpointsT do
		local text = Instance.new("TextBox")
		text.Text = checkpoint.Name
		text.Size = UDim2.new(1, 0, 0, 30)
		text.Position = UDim2.new(0, 0, 0, y)
		text.BackgroundColor3 = Color3.fromRGB(60,60,120)
		text.TextColor3 = checkpoint.Color
		text.Font = Enum.Font.SourceSans
		text.TextSize = 18
		text.TextXAlignment = Enum.TextXAlignment.Left
		text.Parent = checkpointsList
		local textC = Instance.new("TextBox")
		local r,g,b=color3ToRGB(checkpoint.Color)
		textC.Text = tostring(r .. "," .. g .. "," .. b)
		textC.Size = UDim2.new(.5, 0, .5, 0)
		textC.Position = UDim2.new(0, 0, 1,0)
		textC.BackgroundColor3 = Color3.fromRGB(60,60,120)
		textC.TextColor3 = checkpoint.Color
		textC.Font = Enum.Font.SourceSans
		textC.TextScaled = true
		textC.PlaceholderText = "RGB Red (255,0,0)"
	
		textC.TextXAlignment = Enum.TextXAlignment.Left
		textC.Parent = text
		
		local tpBtn = Instance.new("TextButton")
		tpBtn.Text = "Teleport"
		tpBtn.Size = UDim2.new(0, 25, 1, 0)
		tpBtn.Position = UDim2.new(1, -50, 0, 0)
		tpBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
		tpBtn.TextColor3 = Color3.fromRGB(255,255,255)
		tpBtn.Font = Enum.Font.SourceSansBold
		tpBtn.TextScaled = true
		tpBtn.Parent = text
		
		local spawnBtn = Instance.new("TextButton")
		spawnBtn.Text = "Set Spawnpoint"
		spawnBtn.Size = UDim2.new(0, 25, 1, 0)
		spawnBtn.Position = UDim2.new(1, -25, 0, 0)
		spawnBtn.BackgroundColor3 = Color3.fromRGB(22, 99, 120)
		spawnBtn.TextColor3 = Color3.fromRGB(255,255,255)
		spawnBtn.Font = Enum.Font.SourceSansBold
		spawnBtn.TextScaled = true
		spawnBtn.Active = true
		spawnBtn.Parent = text
		
		if currentSpawnpoint == checkpoint then
			spawnBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
			spawnBtn.Active = false
		end
		
		local deleteBtn = Instance.new("TextButton")
		deleteBtn.Text = "Delete"
		deleteBtn.Size = UDim2.new(0, 25, 1, 0)
		deleteBtn.Position = UDim2.new(1, -75, 0, 0)
		deleteBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
		deleteBtn.TextColor3 = Color3.fromRGB(255,255,255)
		deleteBtn.Font = Enum.Font.SourceSansBold
		deleteBtn.TextScaled = true
		deleteBtn.Parent = text
		
		text.FocusLost:Connect(function()
			if text.Text == "" then
				text.Text = tostring(#checkpointsT + 1)
			end
			checkpoint.Name = text.Text
		end)
		
		spawnBtn.MouseButton1Click:Connect(function()
			currentSpawnpoint = checkpoint
			refreshCheckpointsList()
		end)
		
		deleteBtn.MouseButton1Click:Connect(function()
			table.remove(checkpointsT, checkpoint:GetAttribute("Index") or 0)
			if checkpoint == currentSpawnpoint then
				currentSpawnpoint = nil
			end
			checkpoint:Destroy()
			refreshCheckpointsList()
		end)
		
		textC.FocusLost:Connect(function()
			pcall(function()
				local color = textC.Text
				color = color:gsub("%s+", "") -- Remove spaces
				color = color:gsub("[^%d,]", "") -- Remove non-digit and comma characters
				local r = tonumber(color:split(",")[1])
				local g = tonumber(color:split(",")[2])
				local b = tonumber(color:split(",")[3])

				if r and g and b then
					checkpoint.Color = Color3.fromRGB(r, g, b)
				end
			end)

		end)
		
		--detect textbox changes
		textC.Changed:Connect(function(property)
			if property == "Text" then
				pcall(function()

					-- preview color
					local color = textC.Text
					color = color:gsub("%s+", "") -- Remove spaces
					color = color:gsub("[^%d,]", "") -- Remove non-digit and comma characters
					local r = tonumber(color:split(",")[1])
					local g = tonumber(color:split(",")[2])
					local b = tonumber(color:split(",")[3])
					if r and g and b then
						textC.TextColor3 = Color3.fromRGB(r, g, b)
						text.TextColor3 = Color3.fromRGB(r, g, b)
					end
				end)
				
			end
		end)
		
		tpBtn.MouseButton1Click:Connect(function()
			local char = player.Character
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp and checkpoint then
				hrp.CFrame = CFrame.new(Vector3.new(checkpoint.Position.X, checkpoint.Position.Y + 2, checkpoint.Position.Z), Vector3.new(0,0,0))
			end
		end)
		
		y = y + 50
		
	end
	checkpointsList.CanvasSize = UDim2.new(0,0,0,y)
end

checkpoints.MouseButton1Click:Connect(function()
	checkpointsGui.Visible = true
	refreshCheckpointsList()
end)

player.CharacterAdded:Connect(function()
	task.wait(1.5)
	if currentSpawnpoint then
		local char = player.Character
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp and currentSpawnpoint then
			hrp.CFrame = CFrame.new(Vector3.new(currentSpawnpoint.Position.X, currentSpawnpoint.Position.Y + 2, currentSpawnpoint.Position.Z), Vector3.new(0,0,0))
		end
	end
end)

-- FPS and Ping update logic
local RunService = game:GetService("RunService")
local lastTime = tick()
local frameCount = 0
local fps = 0

RunService.RenderStepped:Connect(function()
	frameCount = frameCount + 1
	local now = tick()
	if now - lastTime >= 1 then
		fps = frameCount
		frameCount = 0
		lastTime = now
		fpsLabel.Text = "FPS: " .. tostring(fps)
	end
end)


local function updatePing()
	local ping = math.floor(player:GetNetworkPing() * 1000)
	pingLabel.Text = "Ping: " .. tostring(ping) .. " ms"
end

healthscript()

while true do
	updatePing()
	task.wait(1)
end

