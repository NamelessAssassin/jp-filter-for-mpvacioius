local utils = require('custom_filter.utils')

local state = {
    enabled = true,
    MAX_HISTORY_SIZE = 10,
    MODES = {
        AUTO = "自动检测中...",
        TARGET_TOP = "顶部",
        TARGET_BOTTOM = "底部",
        MONO = "单语模式"
    },
    current_mode = "AUTO",
    threshold = 5,
    scores = {
        TARGET_TOP = 0,
        TARGET_BOTTOM = 0,
        MONO = 0
    },
    last_subtitle_track = nil,
    history = nil
}

local utils = require('custom_filter.utils')

local state = {
    enabled = true,
    MAX_HISTORY_SIZE = 10, -- Config: max history entries
    MODES = {
        AUTO = "自动检测中...",
        TARGET_TOP = "顶部", -- JP_TOP → TARGET_TOP
        TARGET_BOTTOM = "底部", -- JP_BOTTOM → TARGET_BOTTOM
        MONO = "单语模式"
    },
    current_mode = "AUTO",
    threshold = 5,
    scores = {
        TARGET_TOP = 0, -- JP_TOP → TARGET_TOP
        TARGET_BOTTOM = 0, -- JP_BOTTOM → TARGET_BOTTOM
        MONO = 0
    },
    last_subtitle_track = nil,
    history = nil -- Will be initialized as ring buffer
}

-- Initialize history as ring buffer
state.history = utils.create_ring_buffer(state.MAX_HISTORY_SIZE)

function state:toggle()
    self.enabled = not self.enabled
end

function state:get_current_mode_name()
    return self.MODES[self.current_mode] or self.current_mode
end

function state:reset_scores()
    self.current_mode = "AUTO"
    self.scores.TARGET_TOP = 0
    self.scores.TARGET_BOTTOM = 0
    self.scores.MONO = 0
end

function state:get_current_data()
    return {
        current_mode = self.current_mode,
        scores = utils.deep_copy(self.scores)
    }
end

function state:restore_data(data)
    self.current_mode = data.current_mode
    self.scores = utils.deep_copy(data.scores)
end

function state:save_history()
    if self.last_subtitle_track then
        self.history:set(self.last_subtitle_track, self:get_current_data())
    end
end

function state:switch_to(subtitle_track)
    self:save_history()

    if subtitle_track and self.history:get(subtitle_track) then
        self:restore_data(self.history:get(subtitle_track))
    else
        self:reset_scores()
    end

    self.last_subtitle_track = subtitle_track
end

function state:reset_all()
    self.history:clear()
    self.last_subtitle_track = nil
    self:reset_scores()
end

return state
