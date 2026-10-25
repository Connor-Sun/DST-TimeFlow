GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

local MODNAME = "TimeFlow"
local time_scale = 1
local perish_mult = 1

local panel_key_name = GetModConfigData("panel_key") or "KEY_F7"
local panel_key = GLOBAL[panel_key_name] or KEY_F7

local TEXT = {
    en = {
        title = "Time Flow",
        time = "Time Speed",
        perish = "Rot Speed",
        close = "Close",
        pause = "Pause",
        no_rot = "No Rot",
        cancel = "Cancel",
        apply = "Apply",
        say_apply = "Time: %s, rot: %s.",
        time_paused = "paused",
        rot_off = "off",
        no_permission = "Only admins can change time settings.",
    },
    zh = {
        title = "时间流速控制",
        time = "时间流速",
        perish = "腐烂速度",
        close = "关闭",
        pause = "暂停",
        no_rot = "不烂",
        cancel = "取消",
        apply = "应用",
        say_apply = "时间流速：%s，腐烂速度：%s。",
        time_paused = "暂停",
        rot_off = "关闭",
        no_permission = "只有管理员可以调整时间设置。",
    },
    zht = {
        title = "時間流速控制",
        time = "時間流速",
        perish = "腐爛速度",
        close = "關閉",
        pause = "暫停",
        no_rot = "不爛",
        cancel = "取消",
        apply = "應用",
        say_apply = "時間流速：%s，腐爛速度：%s。",
        time_paused = "暫停",
        rot_off = "關閉",
        no_permission = "只有管理員可以調整時間設定。",
    },
}

local function current_locale()
    local code = (LOC and LOC.GetLocaleCode and LOC.GetLocaleCode()) or locale or "en"
    if code == "zh" or code == "zhr" then
        return "zh"
    elseif code == "zht" then
        return "zht"
    end
    return "en"
end

-- 客户端本地状态（面板显示用）
local client_time_scale = 1
local client_perish = perish_mult

local function Notify(player, msg)
    if player and player.components.talker then
        player.components.talker:Say(msg)
    end
end

local function fmt_num(v)
    if v == math.floor(v) then
        return tostring(math.floor(v))
    end
    return string.format("%.2f", v):gsub("0+$", ""):gsub("%.$", "")
end

-- 食物腐烂倍率（0 = 不腐烂）
AddComponentPostInit("perishable", function(self)
    if self.SetLocalMultiplier then
        self:SetLocalMultiplier(perish_mult)
    end
end)

-- 存活天数用的是 GetTime()，需要单独暂停，否则和右上角时钟对不上
local function set_aging_paused(paused)
    for _, player in ipairs(AllPlayers) do
        local age = player.components.age
        if age then
            if paused then
                age:PauseAging()
            else
                age:ResumeAging()
            end
        end
    end
end

local function can_control(player)
    if GetModConfigData("panel_permission") == "everyone" then
        return true
    end
    return player ~= nil
        and player.Network ~= nil
        and player.Network:IsServerAdmin()
end

-- 服务器 RPC：一次应用时间和腐烂，只提示一条
AddModRPCHandler(MODNAME, "Apply", function(player, time, perish)
    if not TheWorld.ismastersim then
        return
    end
    if not can_control(player) then
        return
    end

    time_scale = tonumber(time) or 1
    perish_mult = tonumber(perish) or 1

    set_aging_paused(time_scale == 0)
    for _, ent in pairs(Ents) do
        if ent.components.perishable then
            ent.components.perishable:SetLocalMultiplier(perish_mult)
        end
    end

    local L = TEXT[current_locale()]
    local t = time_scale == 0 and L.time_paused or (fmt_num(time_scale) .. "x")
    local p = perish_mult == 0 and L.rot_off or (fmt_num(perish_mult) .. "x")
    Notify(player, string.format(L.say_apply, t, p))
end)

-- 按倍率推进昼夜与季节；0 = 暂停
AddComponentPostInit("clock", function(self)
    if not TheWorld.ismastersim then
        return
    end

    local old_update = self.OnUpdate
    self.OnUpdate = function(self, dt)
        if time_scale <= 0 then
            return
        end
        return old_update(self, dt * time_scale)
    end

    local old_long_update = self.LongUpdate
    self.LongUpdate = function(self, dt, ...)
        if time_scale <= 0 then
            return
        end
        return old_long_update(self, dt * time_scale, ...)
    end
end)

-- 客户端面板
if not TheNet:IsDedicated() then
    modimport("widgets/pausepanel")
    local PausePanel = GLOBAL.PausePanel
    local key_registered = false
    local was_paused_before_panel = false
    local panel_paused_server = false

    local function client_can_control()
        if GetModConfigData("panel_permission") == "everyone" then
            return true
        end
        return TheNet:GetIsServerAdmin() or TheNet:GetServerIsClientHosted()
    end

    AddClassPostConstruct("screens/playerhud", function(self)
        print("TimeFlow: HUD postinit locale=" .. current_locale())

        self.pausepanel = self:AddChild(PausePanel(nil, {
            can_apply = client_can_control,
            on_apply = function(time, perish)
                if not client_can_control() then
                    return
                end
                client_time_scale = time
                client_perish = perish
                SendModRPCToServer(MOD_RPC[MODNAME]["Apply"], time, perish)
                local hud = ThePlayer and ThePlayer.HUD
                if hud and hud.pausepanel then
                    hud.pausepanel:Toggle()
                end
            end,
            get_state = function()
                return { time = client_time_scale, perish = client_perish }
            end,
            on_open = function()
                was_paused_before_panel = TheNet:IsServerPaused()
                panel_paused_server = false
                if TheNet:GetServerIsClientHosted()
                    and #GetPlayerClientTable() == 1
                    and not was_paused_before_panel then
                    SetServerPaused(true)
                    panel_paused_server = true
                end
            end,
            on_close = function()
                if panel_paused_server then
                    SetServerPaused(false)
                    panel_paused_server = false
                end
            end,
        }, TEXT[current_locale()]))
        self.pausepanel:Hide()
        print("TimeFlow: panel created")

        if not key_registered and TheInput then
            key_registered = true
            TheInput:AddKeyUpHandler(panel_key, function()
                local hud = ThePlayer and ThePlayer.HUD
                if not (hud and hud.pausepanel) then
                    return
                end
                hud.pausepanel:Toggle()
            end)
            print("TimeFlow: " .. panel_key_name .. " registered")
        end
    end)
end
