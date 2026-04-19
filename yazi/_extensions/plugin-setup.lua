-- Plugin setup configurations
require("full-border"):setup {
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
}

require("no-status"):setup()

require("git"):setup {
	-- Order of status signs showing in the linemode
	order = 1500,
}

require("copy-file-contents"):setup({
	append_char = "\n",
	notification = true,
})

require("custom-shell"):setup({
    history_path = "default",
    save_history = true,
    wait = true
    block = true
})

