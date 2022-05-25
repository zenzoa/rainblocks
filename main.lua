-- TODO:
-- game over animation / option to restart
-- line clear confetti
-- 4-line celebration
-- mino images
-- animated background scenes
-- high score

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

tetromino = import "tetromino"
stage = import "stage"

local gfx <const> = playdate.graphics

local buttonRepeatTimerLeft = nil
local buttonRepeatTimerRight = nil
local upHoldTimer = nil

setup = function()
	math.randomseed(playdate.getSecondsSinceEpoch())
	currentStage = stage.create()

	local width, height = playdate.display.getSize()
	local stageWidth = (currentStage.width * tetromino.minoSize)
	local stageHeight = (currentStage.visibleHeight * tetromino.minoSize)
	local offsetX = math.floor((width - stageWidth) / 2)
	local offsetY = math.floor((height - stageHeight) / 2)
	playdate.graphics.setDrawOffset(offsetX, offsetY)

	local menu = playdate.getSystemMenu()
	modeOption = menu:addOptionsMenuItem("mode", { "regular", "dynamic", "chill" }, "regular", function(option)
		currentStage:setMode(option)
	end)
	levelOption = menu:addOptionsMenuItem("level", stage.levelStrings, stage.levelStrings[1], function(option)
		currentStage:setLevel(math.tointeger(option), true)
	end)
	ghostOption = menu:addCheckmarkMenuItem("ghost", currentStage.enableGhost, function(value)
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
		upHoldTimer = playdate.timer.performAfterDelay(currentStage.holdDelay, function()
			currentStage:switchHold()
		end)
	else
		currentStage:hardDrop()
	end
end

playdate.upButtonUp = function()
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
