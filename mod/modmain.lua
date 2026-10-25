GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

local MODNAME = "TimeFlow"
local time_scale = 1
local perish_mult = 1

local panel_key_name = GetModConfigData("panel_key") or "KEY_F7"
local panel_key = GLOBAL[panel_key_name] or KEY_F7

local LOCALE = (locale == "zh" or locale == "zhr") and "zh"
    or (locale == "zht" and "zht" or "en")

local TEXT = {
    en = {
        title = "Time Flow",
        time = "Time Speed",
        perish = "Rot Speed",
        close = "Close",
        pause = "Pause",
        no_rot = "No Rot",
        say_pause = "I paused time. Take a break.",
        say_time = "I set time speed to %s.",
        say_rot_off = "I turned off food spoilage.",
        say_rot = "I set food spoilage to %s.",
    },
    zh = {
        title = "时间流速控制",
        time = "时间流速",
        perish = "腐烂速度",
        close = "关闭",
        pause = "暂停",
        no_rot = "不烂",
        say_pause = "我把时间暂停了，大家先歇会儿。",
        say_time = "我把时间流速调到 %s 倍了。",
        say_rot_off = "我把食物腐烂关掉了，放心囤。",
        say_rot = "我把腐烂速度调到 %s 倍了。",
    },
    zht = {
        title = "時間流速控制",
        time = "時間流速",
        perish = "腐爛速度",
        close = "關閉",
        pause = "暫停",
        no_rot = "不爛",
        say_pause = "我把時間暫停了，大家先歇會兒。",
        say_time = "我把時間流速調到 %s 倍了。",
        say_rot_off = "我把食物腐爛關掉了，放心囤。",
        say_rot = "我把腐爛速度調到 %s 倍了。",
    },
}

local L = TEXT[LOCALE]

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

-- 服务器 RPC
AddModRPCHandler(MODNAME, "SetTimeScale", function(player, val)
    if not TheWorld.ismastersim then
        return
    end
    time_scale = tonumber(val) or 1
    Notify(player, time_scale == 0
        and L.say_pause
        or string.format(L.say_time, fmt_num(time_scale)))
end)

AddModRPCHandler(MODNAME, "SetPerish", function(player, val)
    if not TheWorld.ismastersim then
        return
    end
    perish_mult = tonumber(val) or 1
    for _, ent in pairs(Ents) do
        if ent.components.perishable then
            ent.components.perishable:SetLocalMultiplier(perish_mult)
        end
    end
    Notify(player, perish_mult == 0
        and L.say_rot_off
        or string.format(L.say_rot, fmt_num(perish_mult)))
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

    AddClassPostConstruct("screens/playerhud", function(self)
        print("TimeFlow: HUD postinit")

        self.pausepanel = self:AddChild(PausePanel(nil, {
            on_set_time = function(v)
                client_time_scale = v
                SendModRPCToServer(MOD_RPC[MODNAME]["SetTimeScale"], v)
            end,
            on_set_perish = function(v)
                client_perish = v
                SendModRPCToServer(MOD_RPC[MODNAME]["SetPerish"], v)
            end,
            get_state = function()
                return { time = client_time_scale, perish = client_perish }
            end,
            on_open = function()
                was_paused_before_panel = TheNet:IsServerPaused()
                if not was_paused_before_panel then
                    SetServerPaused(true)
                end
            end,
            on_close = function()
                if not was_paused_before_panel then
                    SetServerPaused(false)
                end
            end,
        }, L))
        self.pausepanel:Hide()
        print("TimeFlow: panel created")

        if not key_registered and TheInput then
            key_registered = true
            TheInput:AddKeyUpHandler(panel_key, function()
                local hud = ThePlayer and ThePlayer.HUD
                if hud and hud.pausepanel then
                    hud.pausepanel:Toggle()
                end
            end)
            print("TimeFlow: " .. panel_key_name .. " registered")
        end
    end)
end
