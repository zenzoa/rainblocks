local stage = {
	maxLevel = 10,
	levelStrings =	{	"01",	"02",	"03",	"04",	"05",	"06",	"07",	"08",	"09",	"10"	},
	speeds =				{	1000,	793,	618,	473,	355,	262,	190,	135,	94,		64		},

	create = function(scenes)
		local s = {
			width = 10,
			height = 22,
			visibleHeight = 20,

			tetromino = nil,
			enablePreview = true,
			preview = nil,
			enableHold = true,
			hold = nil,
			enableGhost = true,
			ghost = nil,

			tiles = {},
			bag = {},

			score = 0,
			scoreDisplay = 0,
			combo = -1,
			linesCleared = 0,
			fourLinesCleared = 0,
			level = 1,

			speed = 1000,
			lockDelay = 500,
			lockTimer = nil,
			tickTimer = nil,
			holdDelay = 500,
			isHardDropping = false,
			isWaitingForHoldLock = false,
			highestLine = 22,
			prevHighestLine = 22,

			isGameOver = false,
			fillSpeed = 1,
			fillTimer = nil,
			fillRow = 22,
			fillCol = 1,

			mode = "dynamic",

			scenes = scenes,
			sceneIndex = 1,

			levelLabelWidth = playdate.graphics.getTextSize("LEVEL"),
			holdLabelWidth = playdate.graphics.getTextSize("HOLD"),

			soundEffects = {
				shift = playdate.sound.sampleplayer.new("sounds/shift"),
				rotate = playdate.sound.sampleplayer.new("sounds/rotate"),
				hold = playdate.sound.sampleplayer.new("sounds/hold"),
				softDrop = playdate.sound.sampleplayer.new("sounds/softDrop"),
				hardDrop = playdate.sound.sampleplayer.new("sounds/hardDrop"),
				collide = playdate.sound.sampleplayer.new("sounds/collide"),
				land = playdate.sound.sampleplayer.new("sounds/land"),
				lock = playdate.sound.sampleplayer.new("sounds/lock"),
				lineClear1 = playdate.sound.sampleplayer.new("sounds/lineClear1"),
				lineClear2 = playdate.sound.sampleplayer.new("sounds/lineClear2"),
				lineClear3 = playdate.sound.sampleplayer.new("sounds/lineClear3"),
				lineClear4 = playdate.sound.sampleplayer.new("sounds/lineClear4"),
				gameOver = playdate.sound.sampleplayer.new("sounds/gameOver")
			},

			setup = function(self)
				self.isGameOver = false

				self.score = 0
				self.scoreDisplay = 0
				self.combo = -1
				self.linesCleared = 0
				self.fourLinesCleared = 0
				self.highestLine = 2
				self.prevHighestLine = 22

				self.tetromino = nil
				self.hold = nil
				self.preview = nil
				self.ghost = nil

				self.sceneIndex = 1
				self.scenes[self.sceneIndex]:open()

				if self.mode ~= "chill" then
					self:setLevel(1, true)
				end

				self.tiles = {}
				for row = 1, self.height do
					self.tiles[row] = {}
					for col = 1, self.width do
						self.tiles[row][col] = 0
					end
				end

				self:resetBag()

				self.tickTimer = playdate.timer.new(self.speed, function() self:tick() end)
				self.tickTimer.repeats = true
			end,

			gameOver = function(self)
				self.isGameOver = true
				self.scenes[self.sceneIndex]:close()
				self.soundEffects.gameOver:play()
				self.tickTimer:remove()
				self.tetromino = nil

				self.fillRow = 22
				self.fillCol = 1
				self.fillTimer = playdate.timer.new(self.fillSpeed, function() self:fill() end)
				self.fillTimer.repeats = true
			end,

			nextStage = function(self)
				local oldSceneIndex = self.sceneIndex
				self.sceneIndex = self.sceneIndex + 1
				if self.sceneIndex > #self.scenes then
					self.sceneIndex = 1
				end
				self.scenes[oldSceneIndex]:close()
				self.scenes[self.sceneIndex]:open()
			end,

			setMode = function(self, mode)
				if self.mode ~= mode then
					self.mode = mode
					ModeOption:setValue(mode)
				end
			end,

			setLevel = function(self, level, setManually)
				if level ~= self.level then
					if self.mode == "chill" and not setManually then
						level = self.level
					end

					if level > Stage.maxLevel then
						level = Stage.maxLevel
					end

					self.level = level

					self.speed = Stage.speeds[level]
					if self.tickTimer then
						self.tickTimer.duration = self.speed
					end

					if not setManually then
						LevelOption:setValue(Stage.levelStrings[level])
					end
				end
			end,

			resetBag = function(self)
				self.bag = {}
				for i = 1, #Tetromino.types do
					table.insert(self.bag, Tetromino.types[i])
				end
				for i = #self.bag, 2, -1 do
					local j = math.random(i)
					self.bag[i], self.bag[j] = self.bag[j], self.bag[i]
				end
			end,

			chooseFromBag = function(self)
				local type = self.bag[1]
				table.remove(self.bag, 1)
				if #self.bag == 0 then
					self:resetBag()
				end
				return type
			end,

			spawnTetromino = function(self)
				local type = self:chooseFromBag()
				local x = 4
				local y = 2
				if type == "I" then
					y = 1
				end

				self.tetromino = Tetromino.create(type, x, y)
				if self.tetromino:checkCollision(self, 0, 0) then
					self:gameOver()
				else
					if self.enableGhost then
						self.ghost = Tetromino.create(type, x, y)
						self.ghost.isGhost = true
					end

					if self.enablePreview then
						self.preview = Tetromino.create(self.bag[1], 0, 0)
					end

					self:tick()
				end
			end,

			shiftLeft = function(self)
				if self.tetromino then
					local success = self.tetromino:moveLeft(self)
					if success then
						self.soundEffects.shift:play()
					else
						self.soundEffects.collide:play()
					end
				end
			end,

			shiftRight = function(self)
				if self.tetromino then
					local success = self.tetromino:moveRight(self)
					if success then
						self.soundEffects.shift:play()
					else
						self.soundEffects.collide:play()
					end
				end
			end,

			rotateClockwise = function(self)
				if self.tetromino then
					local success = self.tetromino:rotateClockwise(self)
					if success then
						self.soundEffects.rotate:play()
					else
						self.soundEffects.collide:play()
					end
				end
			end,

			rotateCounterClockwise = function(self)
				if self.tetromino then
					local success = self.tetromino:rotateCounterClockwise(self)
					if success then
						self.soundEffects.rotate:play()
					else
						self.soundEffects.collide:play()
					end
				end
			end,

			startSoftDrop = function(self)
				if self.tetromino then
					self.soundEffects.softDrop:play(0)
					self.tickTimer.duration = math.floor(self.speed / 20)
				end
			end,

			stopSoftDrop = function(self)
				if self.tetromino then
					self.soundEffects.softDrop:stop()
					self.tickTimer.duration = self.speed
				end
			end,

			hardDrop = function(self)
				if self.tetromino then
					self.isHardDropping = true
					self:tick()
				end
			end,

			switchHold = function(self)
				if self.enableHold and not self.isWaitingForHoldLock then
					self.soundEffects.hold:play()
					if self.hold then
						table.insert(self.bag, 1, self.hold.type)
						self.isWaitingForHoldLock = true
					end
					self.hold = self.tetromino
					self:spawnTetromino()
				end
			end,

			lock = function(self)
				if self.lockTimer then
					self.lockTimer:remove()
					self.lockTimer = nil
				end

				if self.tetromino and self.tetromino:checkCollision(self, 0, 1) then
					self:tetrominoToTiles()
					self.tetromino = nil
					local lineCount = self:checkForLines()
					self:calculateScore(lineCount)

					if self:checkForLockOut() then
						self:gameOver()
					else
						self:checkForSlowDown()
						if lineCount == 0 then
							if self.isHardDropping then
								self.soundEffects.hardDrop:play()
							else
								self.soundEffects.lock:play()
							end
						elseif 1 <= lineCount and lineCount <= 4 then
							self.soundEffects["lineClear" .. lineCount]:play()
						end
					end
				end

				self.isWaitingForHoldLock = false
				self.isHardDropping = false
			end,

			checkForSlowDown = function(self)
				if self.mode == "dynamic" and self.level > 1 and
					self.highestLine < self.prevHighestLine and
					self.highestLine <= 6
					then
						self:setLevel(self.level - 1)
				end
			end,

			checkForLockOut = function(self)
				local tilesAboveVisibleStage = false
				for row = 1, 2 do
					for col = 1, self.width do
						if self.tiles[row][col] > 0 then
							tilesAboveVisibleStage = true
							break
						end
					end
				end
				return tilesAboveVisibleStage
			end,

			checkForLines = function(self)
				self.prevHighestLine = self.highestLine
				self.highestLine = self.height
				local lineCount = 0
				for row = 3, self.height do
					local isLine = true
					for col = 1, self.width do
						if self.tiles[row][col] == 0 then
							isLine = false
						else
							if row < self.highestLine then
								self.highestLine = row
							end
						end
					end
					if isLine then
						self:clearLine(row)
						lineCount = lineCount + 1
					end
				end
				return lineCount
			end,

			clearLine = function(self, y)
				for row = y, 2, -1 do
					for col = 1, self.width do
						self.tiles[row][col] = self.tiles[row - 1][col]
					end
				end
			end,

			tetrominoToTiles = function(self)
				local pattern = Tetromino.pattern[self.tetromino.type]
				local rotation = pattern[self.tetromino.rotationIndex]
				for row = 1, #rotation do
					for col = 1, #rotation[row] do
						if rotation[row][col] > 0 then
							local x = self.tetromino.x + col - 1
							local y = self.tetromino.y + row - 1
							self.tiles[y][x] = rotation[row][col]
						end
					end
				end
			end,

			calculateScore = function(self, lineCount)
				local score = 0

				if lineCount == 1 then
					score = 100 * self.level
				elseif lineCount == 2 then
					score = 300 * self.level
				elseif lineCount == 3 then
					score = 500 * self.level
				elseif lineCount >= 4 then
					score = 800 * self.level
				end

				if lineCount >= 1 then
					self.combo = self.combo + 1
					score = score + (50 * self.combo * self.level)
				else
					self.combo = -1
				end

				self.linesCleared = self.linesCleared + lineCount
				if self.linesCleared >= 10 then
					self.linesCleared = 0
					self:setLevel(self.level + 1)
				end

				if lineCount >= 4 then
					self.fourLinesCleared = self.fourLinesCleared + 1
					if self.fourLinesCleared >= 2 then
						self.fourLinesCleared = 0
						self:nextStage()
					end
				end

				self.score = self.score + score
			end,

			tick = function(self)
				if self.tetromino then

					local success = false
					if self.isHardDropping then
						while self.tetromino:moveDown(self) do
							-- nothing, we're hard-dropping until we hit the bottom
						end
					else
						success = self.tetromino:moveDown(self)
					end

					if success then
						if self.lockTimer then
							self.lockTimer:remove()
							self.lockTimer = nil
						end
					elseif not self.lockTimer then
						local lockDelay = self.lockDelay
						if self.isHardDropping then
							lockDelay = 1
						else
							self.soundEffects.land:play()
						end
						self.lockTimer = playdate.timer.new(lockDelay, function() self:lock() end)
					end

				else
					self:spawnTetromino()
				end
			end,

			fill = function(self)
				self.tiles[self.fillRow][self.fillCol] = math.random(1, 7)

				if self.fillRow % 2 == 0 then
					self.fillCol = self.fillCol + 1
				else
					self.fillCol = self.fillCol - 1
				end

				if self.fillCol < 1 or self.fillCol > self.width then
					self.fillRow = self.fillRow - 1
					if self.fillRow % 2 == 0 then
						self.fillCol = 1
					else
						self.fillCol = self.width
					end
					if self.fillRow > 2 then
						self.soundEffects.collide:play()
					end
				end

				if self.fillRow <= 2 then
					self.soundEffects.land:play()
					self.fillTimer:remove()
					self.fillTimer = nil
				end
			end,

			drawTile = function(self, tx, ty, blockIndex)
				local x = tx * Tetromino.minoSize
				local y = ty * Tetromino.minoSize
				Tetromino.images[blockIndex]:draw(x, y)
			end,

			draw = function(self)
				local displayWidth = self.width * Tetromino.minoSize
				local displayHeight = self.visibleHeight * Tetromino.minoSize

				if self.score > self.scoreDisplay then
					if self.score - self.scoreDisplay >= 1000 then
						self.scoreDisplay = math.min(self.score, self.scoreDisplay + 100)
					elseif self.score - self.scoreDisplay >= 100 then
						self.scoreDisplay = math.min(self.score, self.scoreDisplay + 20)
					else
						self.scoreDisplay = math.min(self.score, self.scoreDisplay + 10)
					end
				end
				playdate.graphics.drawText("SCORE", displayWidth + 10, displayHeight - 26)
				playdate.graphics.drawText(self.scoreDisplay, displayWidth + 10, displayHeight - 10)

				playdate.graphics.drawText("LEVEL", -self.levelLabelWidth - 10, displayHeight - 26)
				self.levelTextWidth = playdate.graphics.getTextSize(self.level)
				playdate.graphics.drawText(self.level, -self.levelTextWidth - 10, displayHeight - 10)

				if self.enablePreview then
					playdate.graphics.drawText("NEXT", displayWidth + 10, 0)
					if self.preview then
						self.preview.x = self.width + 2
						self.preview.y = 5
						self.preview:draw()
					end
				end

				if self.enableHold then
					playdate.graphics.drawText("HOLD", -self.holdLabelWidth - 10, 0)
					if self.hold then
						self.hold.x = -Tetromino.width[self.hold.type]
						self.hold.y = 5
						self.hold:draw()
					end
				end

				playdate.graphics.drawRect(-2, -2, displayWidth + 3, displayHeight + 3)
				playdate.graphics.setClipRect(0, 0, displayWidth, displayHeight)

				if self.tetromino then
					if self.ghost and self.enableGhost then
						self.ghost.x = self.tetromino.x
						self.ghost.y = self.tetromino.y
						self.ghost.rotationIndex = self.tetromino.rotationIndex
						while self.ghost:moveDown(self) do end
						self.ghost:draw()
					end

					self.tetromino:draw()
				end

				for row = 1, self.height do
					for col = 1, self.width do
						if self.tiles[row][col] > 0 then
							local x = col - 1
							local y = row - 3
							self:drawTile(x, y, self.tiles[row][col])
						end
					end
				end

			end,
		}

		s:setup()
		return s
	end
}

return stage