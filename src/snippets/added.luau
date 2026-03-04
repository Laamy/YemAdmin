local Players = game:GetService("Players")

--tempnicks: {[string]: string}, -- TODO: userdata table instead or smth with flags(?)
--tempbans: {[string]: string?},
--tempblacklist: {[string]: {any}},
--tempwhitelist: {[string]: WhitelistData},
type AdminRank = {
    Rank: number,
    Colour: Color3,
}

type UserData = {
    Nickname: string?,
    Banned: boolean?,
    Blacklist: boolean?,

    Rank: AdminRank
}

local PlayerData: {UserData} = {}

setmetatable(PlayerData, {
    __index = function(_t, userid)
        local t: {UserData} = _t
        if not t[userid] then
            t[userid] = {
                Rank = {} :: AdminRank
            }
        end

        return t[userid]
    end
})
