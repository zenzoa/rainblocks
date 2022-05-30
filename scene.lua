local scene = {
	create = function(bgTrackName)
		local s = {
			bgImageTable = Gfx.imagetable.new('images/bg.gif'),
			bgImageIndex = 1,
			bgTrackName = bgTrackName,
			bgTrack = nil,
			animationTimer = nil,
			setup = function(self)
				self.bgTrack = playdate.sound.fileplayer.new("music/" .. self.bgTrackName)
				self.bgTrack:setVolume(0.5)
			end,
			open = function(self)
				self.bgTrack:play(0)
				self.animationTimer = playdate.timer.new(500, function() self:nextFrame() end)
				self.animationTimer.repeats = true
			end,
			close = function(self)
				self.bgTrack:stop()
				self.animationTimer:remove()
			end,
			nextFrame = function(self)
				print("nextframe")
				self.bgImageIndex = self.bgImageIndex + 1
				if self.bgImageIndex > self.bgImageTable:getLength() then
					self.bgImageIndex = 1
				end
			end,
			draw = function(self)
				local bgImage = self.bgImageTable:getImage(self.bgImageIndex)
				bgImage:drawIgnoringOffset(0, 0)
			end
		}

		s:setup()
		return s
	end
}

return scene