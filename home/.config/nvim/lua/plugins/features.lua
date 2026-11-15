-- Applies lua/config/features.lua: disable only the plugins set to false.
local spec = {}
for name, on in pairs(require("config.features").plugins) do
  if not on then
    spec[#spec + 1] = { name, enabled = false }
  end
end
return spec
