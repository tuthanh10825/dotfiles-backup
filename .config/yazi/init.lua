require("full-border"):setup({
	type = ui.Border.PLAIN,
})
require("relative-motions"):setup({ show_numbers = "relative", show_motion = true, enter_mode = "first" })
require("yatline"):setup({
	show_background = false,

	header_line = {
		left = {
			section_a = {
				{ type = "line", custom = false, name = "tabs", params = { "left" } },
			},
			section_b = {},
			section_c = {},
		},
		right = {
			section_a = {
				{ type = "string", custom = false, name = "date", params = { "%A, %d %B %Y" } },
			},
			section_b = {
				{ type = "string", custom = false, name = "date", params = { "%X" } },
			},
			section_c = {},
		},
	},

	status_line = {
		left = {
			section_a = {
				{ type = "string", custom = false, name = "tab_mode" },
			},
			section_b = {
				{ type = "string", custom = false, name = "hovered_size" },
			},
			section_c = {
				{ type = "string", custom = false, name = "hovered_path" },
				{ type = "coloreds", custom = false, name = "count" },
			},
		},
		right = {
			section_a = {
				{ type = "string", custom = false, name = "cursor_position" },
			},
			section_b = {
				{ type = "string", custom = false, name = "cursor_percentage" },
			},
			section_c = {
				{ type = "string", custom = false, name = "hovered_file_extension", params = { true } },
				{ type = "coloreds", custom = false, name = "permissions" },
			},
		},
	},
})
require("yatline-githead"):setup({
	show_branch = true,
	branch_prefix = "on",
	prefix_color = "white",
	branch_color = "blue",
	branch_symbol = "",
	branch_borders = "()",

	commit_color = "bright magenta",
	commit_symbol = "@",

	show_behind_ahead = true,
	behind_color = "bright magenta",
	behind_symbol = "⇣",
	ahead_color = "bright magenta",
	ahead_symbol = "⇡",

	show_stashes = true,
	stashes_color = "bright magenta",
	stashes_symbol = "$",

	show_state = true,
	show_state_prefix = true,
	state_color = "red",
	state_symbol = "~",

	show_staged = true,
	staged_color = "bright yellow",
	staged_symbol = "+",

	show_unstaged = true,
	unstaged_color = "bright yellow",
	unstaged_symbol = "!",

	show_untracked = true,
	untracked_color = "blue",
	untracked_symbol = "?",
})
