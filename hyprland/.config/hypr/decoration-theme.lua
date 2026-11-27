-- Share the accent palette and theme selection with Quickshell.
local function read(path)
	local file = io.open(path, "r")
	if not file then return "" end
	local content = file:read("*a") or ""
	file:close()
	return content
end

local function apply()
	local home = os.getenv("HOME")
	local state = os.getenv("XDG_STATE_HOME")
	if not state or state == "" then state = home .. "/.local/state" end
	local selected = read(state .. "/quickshell/theme"):match("^%s*(%a+)%s*$")
	if selected ~= "lavender" then selected = "original" end

	local palette = read(home .. "/dotfiles/quickshell/.config/quickshell/theme/accents")
	local accent = "8dccad"
	for name, hex in palette:gmatch("(%a+)=([%da-f]+)") do
		if name == selected and #hex == 6 then accent = hex end
	end

	hl.config({
		general = { col = { active_border = "rgba(" .. accent .. "ff)" } },
		decoration = { glow = { color = "rgba(" .. accent .. "38)" } },
	})
end

return { apply = apply }
