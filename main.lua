-- TODO:
-- game over animation / option to restart
-- line clear confetti
-- 4-line celebration
-- animated background scenes
-- high score

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

Tetromino = import "tetromino"
Stage = import "stage"
Scene = import "scene"

local gfx <const> = playdate.graphics

local currentStage
local buttonRepeatTimerLeft = nil
local buttonRepeatTimerRight = nil
local upHoldTimer = nil

local defaultFont

local scenes = {}

local setup = function()
	math.randomseed(playdate.getSecondsSinceEpoch())

	defaultFont = playdate.graphics.font.new("fonts/krull")
	playdate.graphics.setFont(defaultFont)

	scenes = {
		Scene.create("something_in_the_air"),
		Scene.create("glad_to_be_stuck_inside"),
		Scene.create("mundane"),
		Scene.create("pretty_little_lies"),
		Scene.create("shut_up_or_shut_in"),
		Scene.create("yesterday"),
		Scene.create("whatever"),
	}

	Tetromino:loadImages()
	currentStage = Stage.create(scenes)

	local width, height = playdate.display.getSize()
	local stageWidth = (currentStage.width * Tetromino.minoSize)
	local stageHeight = (currentStage.visibleHeight * Tetromino.minoSize)
	local offsetX = math.floor((width - stageWidth) / 2)
	local offsetY = math.floor((height - stageHeight) / 2)
	playdate.graphics.setDrawOffset(offsetX, offsetY)

	local menu = playdate.getSystemMenu()
	ModeOption = menu:addOptionsMenuItem("mode", { "regular", "dynamic", "chill" }, currentStage.mode, function(option)
		currentStage:setMode(option)
	end)
	LevelOption = menu:addOptionsMenuItem("level", Stage.levelStrings, Stage.levelStrings[1], function(option)
		currentStage:setLevel(math.tointeger(option), true)
	end)
	GhostOption = menu:addCheckmarkMenuItem("ghost", currentStage.enableGhost, function(value)
		currentStage.enableGhost = value
	end)
end

setup()

playdate.AButtonDown = function()
	currentStage:rotateClockwise()
end

playdate.BButtonDown = function()
	currentStage:rotateCounterClockwise()
end

playdate.upButtonDown = function()
	if currentStage.enableHold then
		currentStage.tickTimer:pause()
		upHoldTimer = playdate.timer.performAfterDelay(currentStage.holdDelay, function()
			currentStage:switchHold()
		end)
	else
		currentStage:hardDrop()
	end
end

playdate.upButtonUp = function()
	currentStage.tickTimer:start()
	if currentStage.enableHold and upHoldTimer.timeLeft > 0 then
		upHoldTimer:remove()
		currentStage:hardDrop()
	end
end

playdate.downButtonDown = function()
	currentStage:startSoftDrop()
end

playdate.downButtonUp = function()
	currentStage:stopSoftDrop()
end

playdate.leftButtonDown = function()
	buttonRepeatTimerLeft = playdate.timer.keyRepeatTimer(function() currentStage:shiftLeft() end)
end

playdate.leftButtonUp = function()
	buttonRepeatTimerLeft:remove()
end

playdate.rightButtonDown = function()
	buttonRepeatTimerRight = playdate.timer.keyRepeatTimer(function() currentStage:shiftRight() end)
end

playdate.rightButtonUp = function()
	buttonRepeatTimerRight:remove()
end

playdate.update = function()
	playdate.graphics.clear()

	currentStage:draw()

	gfx.sprite.update()
	playdate.timer.updateTimers()
end
