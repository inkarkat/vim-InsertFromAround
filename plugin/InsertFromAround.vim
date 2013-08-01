" InsertFromAround.vim: Insert-mode mappings to fetch text or indent from surrounding lines.
"
" DEPENDENCIES:
"   - InsertFromAround/Indent.vim autoload script
"   - InsertFromAround/Newline.vim autoload script
"   - InsertFromAround/Text.vim autoload script
"
" Copyright: (C) 2009-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	002	04-Jun-2013	FIX: <S-CR> mapping broken by incomplete
"				factoring out of <SID>(RecordColumn).
"	001	14-Apr-2013	file creation from ingomappings.vim

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_InsertFromAround') || (v:version < 700)
    finish
endif
let g:loaded_InsertFromAround = 1

inoremap <expr> <SID>(RecordColumn) InsertFromAround#Newline#RecordColumn()
inoremap <silent> <script> <S-CR> <SID>(RecordColumn)$<Left><CR><Esc>:call InsertFromAround#Newline#Insert()<CR>
" This will repeat the <Enter> or just the text entered after the mapping (if
" done) on "." in normal mode.

" Now using toggling, see below.
"inoremap <silent> <Plug>InsertFromBelow <C-r><C-r>=<SID>InsertFromAround(0,'.')<CR>
"inoremap <silent> <Plug>InsertFromAbove <C-r><C-r>=<SID>InsertFromAround(1,'.')<CR>
" Additionally overloaded with "Inline Completion" and moved to ingocompletion.vim.
"imap <expr> <C-e> pumvisible() ? '<C-e>' : '<Plug>InsertFromBelow'
"imap <expr> <C-y> pumvisible() ? '<C-y>' : '<Plug>InsertFromAbove'

" Now using toggling, see below.
"inoremap <silent> <C-g><C-e> <C-r><C-r>=<SID>InsertWordFromAround(0)<CR>
"inoremap <silent> <C-g><C-y> <C-r><C-r>=<SID>InsertWordFromAround(1)<CR>

inoremap <silent> <Plug>InsertFromBelow <C-r><C-r>=InsertFromAround#Text#Toggled(0,0)<CR>
inoremap <silent> <Plug>InsertFromAbove <C-r><C-r>=InsertFromAround#Text#Toggled(1,0)<CR>
inoremap <silent> <C-g><C-e> <C-r><C-r>=InsertFromAround#Text#Toggled(0,1)<CR>
inoremap <silent> <C-g><C-y> <C-r><C-r>=InsertFromAround#Text#Toggled(1,1)<CR>



" Use i_CTRL-R_CTRL-O to insert the indent literally without auto-indenting.
inoremap <silent> <C-g><C-u> <C-r><C-o>=InsertFromAround#Indent#Insert()<CR>



" Use i_CTRL-R to insert the indenting <Tab> characters as typed, so that the
" indent settings apply and the added whitespace is fused with preceding
" whitespace.
inoremap <silent> <C-g><C-d> <C-r>=InsertFromAround#Align#AlignToPrevious()<CR>
" For dedenting, we directly manipulate the line with setline(), and only
" possibly return typed characters to cause a beep.
inoremap <silent> <C-g><C-t> <C-r>=InsertFromAround#Align#AlignToNext()<CR>

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
