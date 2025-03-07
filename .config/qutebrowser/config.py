config.load_autoconfig()
config.source('qutewal.py')
c.auto_save.session = True
c.downloads.prevent_mixed_content = False
c.fonts.default_family = "CaskaydiaCove Nerd Font"
c.fonts.prompts = "CaskaydiaCove"
c.fonts.contextmenu = "CaskaydiaCove"
c.fonts.web.family.standard = "CaskaydiaCove Nerd Font"
c.fonts.web.family.fixed = "CaskaydiaCove Nerd Font"
c.fonts.web.family.sans_serif = "CaskaydiaCove Nerd Font"
c.fonts.web.family.serif = "CaskaydiaCove Nerd Font"
c.fonts.tooltip = "CaskaydiaCove Nerd Font"
c.fonts.web.family.fantasy = "CaskaydiaCove Nerd Font"
c.fonts.web.family.cursive = "CaskaydiaCove Nerd Font"
c.tabs.last_close = "startpage"
c.tabs.show = "switching"
c.tabs.show_switching_delay = 500
c.tabs.width = '25%'
c.url.start_pages = ["https://www.google.com"]
c.url.default_page = 'https://www.google.com'
c.url.searchengines = {
        'DEFAULT': 'https://google.com/search?q={}'
        }
c.tabs.position = "left"

