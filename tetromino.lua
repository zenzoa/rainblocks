local tetromino = {
	minoSize = 12,

	types = {
		"I",
		"J",
		"L",
		"S",
		"Z",
		"T",
		"O",
	},

	width = {
		I = 4,
		J = 3,
		L = 3,
		S = 3,
		Z = 3,
		T = 3,
		O = 3,
	},

	pattern = {
		I = {
			{
				{ 0, 0, 0, 0 },
				{ 1, 1, 1, 1 },
				{ 0, 0, 0, 0 },
				{ 0, 0, 0, 0 },
			},
			{
				{ 0, 0, 1, 0 },
				{ 0, 0, 1, 0 },
				{ 0, 0, 1, 0 },
				{ 0, 0, 1, 0 },
			},
			{
				{ 0, 0, 0, 0 },
				{ 0, 0, 0, 0 },
				{ 1, 1, 1, 1 },
				{ 0, 0, 0, 0 },
			},
			{
				{ 0, 1, 0, 0 },
				{ 0, 1, 0, 0 },
				{ 0, 1, 0, 0 },
				{ 0, 1, 0, 0 },
			},
		},
		J = {
			{
				{ 2, 0, 0 },
				{ 2, 2, 2 },
				{ 0, 0, 0 },
			},
			{
				{ 0, 2, 2 },
				{ 0, 2, 0 },
				{ 0, 2, 0 },
			},
			{
				{ 0, 0, 0 },
				{ 2, 2, 2 },
				{ 0, 0, 2 },
			},
			{
				{ 0, 2, 0 },
				{ 0, 2, 0 },
				{ 2, 2, 0 },
			},
		},
		L = {
			{
				{ 0, 0, 3 },
				{ 3, 3, 3 },
				{ 0, 0, 0 },
			},
			{
				{ 0, 3, 0 },
				{ 0, 3, 0 },
				{ 0, 3, 3 },
			},
			{
				{ 0, 0, 0 },
				{ 3, 3, 3 },
				{ 3, 0, 0 },
			},
			{
				{ 3, 3, 0 },
				{ 0, 3, 0 },
				{ 0, 3, 0 },
			},
		},
		S = {
			{
				{ 0, 4, 4 },
				{ 4, 4, 0 },
				{ 0, 0, 0 },
			},
			{
				{ 0, 4, 0 },
				{ 0, 4, 4 },
				{ 0, 0, 4 },
			},
			{
				{ 0, 0, 0 },
				{ 0, 4, 4 },
				{ 4, 4, 0 },
			},
			{
				{ 4, 0, 0 },
				{ 4, 4, 0 },
				{ 0, 4, 0 },
			},
		},
		Z = {
			{
				{ 5, 5, 0 },
				{ 0, 5, 5 },
				{ 0, 0, 0 },
			},
			{
				{ 0, 0, 5 },
				{ 0, 5, 5 },
				{ 0, 5, 0 },
			},
			{
				{ 0, 0, 0 },
				{ 5, 5, 0 },
				{ 0, 5, 5 },
			},
			{
				{ 0, 5, 0 },
				{ 5, 5, 0 },
				{ 5, 0, 0 },
			},
		},
		T = {
			{
				{ 0, 6, 0 },
				{ 6, 6, 6 },
				{ 0, 0, 0 },
			},
			{
				{ 0, 6, 0 },
				{ 0, 6, 6 },
				{ 0, 6, 0 },
			},
			{
				{ 0, 0, 0 },
				{ 6, 6, 6 },
				{ 0, 6, 0 },
			},
			{
				{ 0, 6, 0 },
				{ 6, 6, 0 },
				{ 0, 6, 0 },
			},
		},
		O = {
			{
				{ 0, 7, 7, 0 },
				{ 0, 7, 7, 0 },
				{ 0, 0, 0, 0 },
			},
			{
				{ 0, 7, 7, 0 },
				{ 0, 7, 7, 0 },
				{ 0, 0, 0, 0 },
			},
			{
				{ 0, 7, 7, 0 },
				{ 0, 7, 7, 0 },
				{ 0, 0, 0, 0 },
			},
			{
				{ 0, 7, 7, 0 },
				{ 0, 7, 7, 0 },
				{ 0, 0, 0, 0 },
			},
		},
	},

	images = {},

	loadImages = function(self)
		self.images = {
			Gfx.image.new('images/block2.png'),
			Gfx.image.new('images/block6.png'),
			Gfx.image.new('images/block7.png'),
			Gfx.image.new('images/block4.png'),
			Gfx.image.new('images/block5.png'),
			Gfx.image.new('images/block1.png'),
			Gfx.image.new('images/block3.png'),
			ghost = Gfx.image.new('images/block0.png')
		}
	end,

	create = function(type, xStart, yStart)
		local t = {

			type = type,
			x = xStart,
			y = yStart,
			rotationIndex = 1,
			isGhost = false,

			moveDown = function(self, stage)
				if self:checkCollision(stage, 0, 1) then
					return false
				else
					self.y = self.y + 1
					return true
				end
			end,

			moveLeft = function(self, stage)
				if self:checkCollision(stage, -1, 0) then
					return false
				else
					self.x = self.x - 1
					return true
				end
			end,

			moveRight = function(self, stage)
				if self:checkCollision(stage, 1, 0) then
					return false
				else
					self.x = self.x + 1
					return true
				end
			end,

			rotateClockwise = function(self, stage)
				local newRotationIndex = self.rotationIndex + 1
				if newRotationIndex > 4 then
					newRotationIndex = 1
				end
				return self:rotate(stage, newRotationIndex)
			end,

			rotateCounterClockwise = function(self, stage)
				local newRotationIndex = self.rotationIndex - 1
				if newRotationIndex < 1 then
					newRotationIndex = 4
				end
				return self:rotate(stage, newRotationIndex)
			end,

			rotate = function(self, stage, newRotationIndex)
				if not self:checkCollision(stage, 0, 0, newRotationIndex) then
					self.rotationIndex = newRotationIndex
					return true
				elseif not self:checkCollision(stage, 1, 0, newRotationIndex) then
					self.x = self.x + 1
					self.rotationIndex = newRotationIndex
					return true
				elseif not self:checkCollision(stage, -1, 0, newRotationIndex) then
					self.x = self.x - 1
					self.rotationIndex = newRotationIndex
					return true
				else
					return false
				end
			end,

			checkCollision = function(self, stage, dx, dy, rotationIndex)
				if not rotationIndex then
					rotationIndex = self.rotationIndex
				end
				local pattern = Tetromino.pattern[self.type]
				local rotation = pattern[rotationIndex]
				for row = 1, #rotation do
					for col = 1, #rotation[row] do
						if rotation[row][col] > 0 then
							local x = self.x + dx + col - 1
							local y = self.y + dy + row - 1
							if x < 1 then
								return true
							elseif x > stage.width then
								return true
							elseif y > stage.height then
								return true
							elseif stage.tiles[y][x] > 0 then
								return true
							end
						end
					end
				end
				return false
			end,

			drawMino = function(self, tx, ty, blockIndex, drawBackground)
				local x = tx * Tetromino.minoSize
				local y = ty * Tetromino.minoSize
				if drawBackground then
					Gfx.setColor(Gfx.kColorWhite)
					Gfx.fillRoundRect(x - 1, y - 1, Tetromino.minoSize + 1, Tetromino.minoSize + 1, 1)
					Gfx.setColor(Gfx.kColorBlack)
				end
				if self.isGhost then
					Tetromino.images.ghost:draw(x, y)
				else
					Tetromino.images[blockIndex]:draw(x, y)
				end
			end,

			draw = function(self, drawBackground)
				local pattern = Tetromino.pattern[self.type]
				local rotation = pattern[self.rotationIndex]
				for row = 1, #rotation do
					for col = 1, #rotation[row] do
						if rotation[row][col] > 0 then
							local x = self.x + col - 2
							local y = self.y + row - 4
							self:drawMino(x, y, rotation[row][col], drawBackground)
						end
					end
				end
			end,

		}
		return t
	end
}

return tetromino
