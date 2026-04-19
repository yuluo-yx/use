-- Custom linemode: show file size and mtime
function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%b %d %H:%M", time)
	else
		time = os.date("%b %d  %Y", time)
	end

	local size = self._file:size()
	local size_span = ui.Span(size and ya.readable_size(size) or "-"):style(ui.Style():fg("green"))
	local time_span = ui.Span(time):style(ui.Style():fg("cyan"))
	return ui.Line({ size_span, ui.Span(" "), time_span })
end