local is_s = locale == "zh" or locale == "zhr"
local is_t = locale == "zht"

local desc_en = "Time and rot control panel.\n\n"
    .. "Time speed: Pause / 0.5x / 0.75x / 1x / 1.5x / 2x. "
    .. "Only affects day/night and seasons; players, creatures and building are unaffected.\n\n"
    .. "Rot speed: No Rot / 0.1x / 0.25x / 0.5x / 0.75x / 1x.\n\n"
    .. "Press F7 (configurable in mod settings) to open the panel."

local desc_s = "时间与腐烂调节面板。\n\n"
    .. "时间流速：暂停 / 0.5x / 0.75x / 1x / 1.5x / 2x。只影响昼夜与季节，玩家、生物和建造不受影响。\n\n"
    .. "腐烂速度：不烂 / 0.1x / 0.25x / 0.5x / 0.75x / 1x。\n\n"
    .. "按 F7（可在模组配置中修改）打开面板。"

local desc_t = "時間與腐爛調節面板。\n\n"
    .. "時間流速：暫停 / 0.5x / 0.75x / 1x / 1.5x / 2x。只影響晝夜與季節，玩家、生物和建造不受影響。\n\n"
    .. "腐爛速度：不爛 / 0.1x / 0.25x / 0.5x / 0.75x / 1x。\n\n"
    .. "按 F7（可在模組配置中修改）打開面板。"

name = "Time Flow"
description = is_s and desc_s or (is_t and desc_t or desc_en)
author = "Connor"
version = "0.3.0"

api_version = 10
api_version_dst = 10
dst_compatible = true
dont_starve_compatible = false

client_only_mod = false
all_clients_require_mod = true
server_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = { "pause", "time" }

configuration_options = {
    {
        name = "panel_key",
        label = is_s and "打开面板快捷键"
            or (is_t and "開啟面板快捷鍵" or "Open Panel Key"),
        options = {
            { description = "F7", data = "KEY_F7" },
            { description = "F8", data = "KEY_F8" },
            { description = "F9", data = "KEY_F9" },
            { description = "P", data = "KEY_P" },
            { description = "O", data = "KEY_O" },
        },
        default = "KEY_F7",
    },
}
