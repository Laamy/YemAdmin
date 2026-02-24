local repo = "Laamy/YemAdmin"
local branch = "master"

local code = game:GetService("HttpService"):GetAsync(`https://raw.githubusercontent.com/{repo}/refs/heads/{branch}/src/admin.lua`)
local chunk, loadErr = loadstring(code, "Cattails")
assert(chunk, `Failed to get admin.lua; {loadErr}`)
chunk()