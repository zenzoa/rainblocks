local scene = {
	create = function(backgroundTrackName)
		local s = {
			backgroundTrackName = backgroundTrackName,
			backgroundTrack = nil,
			setup = function(self)
				self.backgroundTrack = playdate.sound.fileplayer.new("music/" .. self.backgroundTrackName)
				self.backgroundTrack:setVolume(0.5)
			end,
			open = function(self)
				self.backgroundTrack:play(0)
			end,
			close = function(self)
				self.backgroundTrack:stop()
			end,
		}

		s:setup()
		return s
	end
}

return scene