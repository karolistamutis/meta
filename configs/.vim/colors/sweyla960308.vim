" Generated by Color Theme Generator at Sweyla
" http://sweyla.com/themes/seed/960308/

set background=dark

hi clear

if exists("syntax_on")
  syntax reset
endif

" Set environment to 256 colours
set t_Co=256

let colors_name = "sweyla960308"

if version >= 700
  hi CursorLine     guibg=#0D0404 ctermbg=232
  hi CursorColumn   guibg=#0D0404 ctermbg=232
  hi MatchParen     guifg=#FF8D39 guibg=#0D0404 gui=bold ctermfg=209 ctermbg=232 cterm=bold
  hi Pmenu          guifg=#FFFFFF guibg=#323232 ctermfg=255 ctermbg=236
  hi PmenuSel       guifg=#FFFFFF guibg=#C59600 ctermfg=255 ctermbg=172
endif

" Background and menu colors
hi Cursor           guifg=NONE guibg=#FFFFFF ctermbg=255 gui=none
hi Normal           guifg=#FFFFFF guibg=#0D0404 gui=none ctermfg=255 ctermbg=232 cterm=none
hi NonText          guifg=#FFFFFF guibg=#1C1313 gui=none ctermfg=255 ctermbg=233 cterm=none
hi LineNr           guifg=#3B3333 guibg=#261D1D gui=none ctermfg=237 ctermbg=234 cterm=none
hi StatusLine       guifg=#FFFFFF guibg=#312103 gui=italic ctermfg=255 ctermbg=234 cterm=italic
hi StatusLineNC     guifg=#FFFFFF guibg=#352C2C gui=none ctermfg=255 ctermbg=236 cterm=none
hi VertSplit        guifg=#FFFFFF guibg=#261D1D gui=none ctermfg=255 ctermbg=234 cterm=none
hi Folded           guifg=#FFFFFF guibg=#0D0404 gui=none ctermfg=255 ctermbg=232 cterm=none
hi Title            guifg=#C59600 guibg=NONE	gui=bold ctermfg=172 ctermbg=NONE cterm=bold
hi Visual           guifg=#FF009F guibg=#323232 gui=none ctermfg=199 ctermbg=236 cterm=none
hi SpecialKey       guifg=#866D5A guibg=#1C1313 gui=none ctermfg=95 ctermbg=233 cterm=none
"hi DiffChange       guibg=#554F02 gui=none ctermbg=58 cterm=none
"hi DiffAdd          guibg=#2E284F gui=none ctermbg=236 cterm=none
"hi DiffText         guibg=#6D3468 gui=none ctermbg=242 cterm=none
"hi DiffDelete       guibg=#490303 gui=none ctermbg=52 cterm=none
 
hi DiffChange       guibg=#4C4C09 gui=none ctermbg=234 cterm=none
hi DiffAdd          guibg=#252556 gui=none ctermbg=17 cterm=none
hi DiffText         guibg=#66326E gui=none ctermbg=22 cterm=none
hi DiffDelete       guibg=#3F000A gui=none ctermbg=0 ctermfg=196 cterm=none
hi TabLineFill      guibg=#5E5E5E gui=none ctermbg=235 ctermfg=228 cterm=none
hi TabLineSel       guifg=#FF009F gui=bold ctermfg=199 cterm=bold


" Syntax highlighting
hi Comment guifg=#C59600 gui=none ctermfg=172 cterm=none
hi Constant guifg=#866D5A gui=none ctermfg=95 cterm=none
hi Number guifg=#866D5A gui=none ctermfg=95 cterm=none
hi Identifier guifg=#B2C500 gui=none ctermfg=148 cterm=none
hi Statement guifg=#FF8D39 gui=none ctermfg=209 cterm=none
hi Function guifg=#AA9B47 gui=none ctermfg=137 cterm=none
hi Special guifg=#83926F gui=none ctermfg=101 cterm=none
hi PreProc guifg=#83926F gui=none ctermfg=101 cterm=none
hi Keyword guifg=#FF8D39 gui=none ctermfg=209 cterm=none
hi String guifg=#FF009F gui=none ctermfg=199 cterm=none
hi Type guifg=#6D6C2B gui=none ctermfg=242 cterm=none
hi pythonBuiltin guifg=#B2C500 gui=none ctermfg=148 cterm=none
hi TabLineFill guifg=#6D0242 gui=none ctermfg=53 cterm=none

