syntax enable
colorscheme deus

"Turn off macro recording"
map q <Nop>

"Text indentation"
set smartindent
set tabstop=2
set shiftwidth=2
set expandtab
set nowrap linebreak textwidth=0
set backspace=indent,eol,start

"Turn off vi compatibility"
set nocompatible

"No octal numbers"
set nrformats-=octal

"Show line numbers"
set number

"Toggle paste mode"
set pastetoggle=<F2>

"Pathogen plugin manager"
execute pathogen#infect()

