local Widget = require("widgets/widget")
local TEMPLATES = require("widgets/redux/templates")

local LABEL_W = 300
local SPIN_W = 225
local ROW_H = 40
local ROW_W = LABEL_W + SPIN_W + 30

local function index_of(options, value)
    for i, opt in ipairs(options) do
        if math.abs(opt.data - value) < 0.001 then
            return i
        end
    end
    return 1
end

local function make_row(parent, label, options, y, onchanged)
    local row = parent:AddChild(Widget("option_row"))
    row:SetPosition(0, y, 0)
    row.bg = row:AddChild(TEMPLATES.ListItemBackground(ROW_W, ROW_H))
    row.opt = row:AddChild(TEMPLATES.LabelSpinner(
        label, options, LABEL_W, SPIN_W, ROW_H,
        5, "bellefair", 25, 0, onchanged))
    return row
end

local PausePanel = Class(Widget, function(self, callbacks, texts)
    Widget._ctor(self, "PausePanel")
    self.callbacks = callbacks or {}
    local T = texts or {}

    self:SetHAnchor(ANCHOR_MIDDLE)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.window = self:AddChild(TEMPLATES.RectangleWindow(
        ROW_W + 20, 320, T.title or "Time Flow"))
    self.window:SetScale(0.8, 0.8)

    self.time_options = {
        { text = T.pause or "Pause", data = 0 },
        { text = "0.5x", data = 0.5 },
        { text = "0.75x", data = 0.75 },
        { text = "1x", data = 1 },
        { text = "1.5x", data = 1.5 },
        { text = "2x", data = 2 },
    }

    self.perish_options = {
        { text = T.no_rot or "No Rot", data = 0 },
        { text = "0.1x", data = 0.1 },
        { text = "0.25x", data = 0.25 },
        { text = "0.5x", data = 0.5 },
        { text = "0.75x", data = 0.75 },
        { text = "1x", data = 1 },
    }

    self.selected_time = 1
    self.selected_perish = 1

    self.time_row = make_row(self.window, T.time or "Time Speed",
        self.time_options, 55,
        function(data)
            self.selected_time = data
        end)

    self.perish_row = make_row(self.window, T.perish or "Rot Speed",
        self.perish_options, -15,
        function(data)
            self.selected_perish = data
        end)

    self.cancel_btn = self.window:AddChild(TEMPLATES.StandardButton(function()
        self:Toggle()
    end, T.cancel or "Cancel", { 140, 40 }))
    self.cancel_btn:SetPosition(-85, -110, 0)

    self.apply_btn = self.window:AddChild(TEMPLATES.StandardButton(function()
        self.callbacks.on_apply(self.selected_time, self.selected_perish)
    end, T.apply or "Apply", { 140, 40 }))
    self.apply_btn:SetPosition(85, -110, 0)

    if self.callbacks.can_apply and not self.callbacks.can_apply() then
        self.apply_btn:Disable()
    end

    self:Refresh()
end)

local function set_spin(row, options, value)
    local spinner = row.opt.spinner
    local fn = spinner.onchangedfn
    spinner.onchangedfn = nil
    spinner:SetSelectedIndex(index_of(options, value))
    spinner.onchangedfn = fn
end

function PausePanel:Refresh()
    if not self.callbacks.get_state then
        return
    end
    local st = self.callbacks.get_state()
    self.selected_time = st.time
    self.selected_perish = st.perish
    set_spin(self.time_row, self.time_options, st.time)
    set_spin(self.perish_row, self.perish_options, st.perish)
end

function PausePanel:Toggle()
    if self.shown then
        self:Hide()
        if self.callbacks.on_close then
            self.callbacks.on_close()
        end
    else
        self:Refresh()
        self:Show()
        self:MoveToFront()
        if self.callbacks.on_open then
            self.callbacks.on_open()
        end
    end
end

GLOBAL.PausePanel = PausePanel
