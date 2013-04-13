" InsertFromAround.vim: Insert-mode mappings to fetch text or indent from surrounding lines.
"
" DEPENDENCIES:
"   - InsertFromAround.vim autoload script
"
" Copyright: (C) 2009-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	14-Apr-2013	file creation from ingomappings.vim

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_InsertFromAround') || (v:version < 700)
    finish
endif
let g:loaded_InsertFromAround = 1

inoremap <expr> <SID>RecordColumn InsertFromAround#RecordColumn()
inoremap <silent> <script> <S-CR> InsertFromAround#RecordColumn$<Left><CR><Esc>:call InsertFromAround#IndentNewLine()<CR>
" This will repeat the <Enter> or just the text entered after the mapping (if
" done) on "." in normal mode.

" Now using toggling, see below.
"inoremap <silent> <Plug>InsertFromBelow <C-R><C-R>=<SID>InsertFromAround(0,'.')<CR>
"inoremap <silent> <Plug>InsertFromAbove <C-R><C-R>=<SID>InsertFromAround(1,'.')<CR>
" Additionally overloaded with "Inline Completion" and moved to ingocompletion.vim.
"imap <expr> <C-E> pumvisible() ? '<C-E>' : '<Plug>InsertFromBelow'
"imap <expr> <C-Y> pumvisible() ? '<C-Y>' : '<Plug>InsertFromAbove'

" Now using toggling, see below.
"inoremap <silent> <C-G><C-E> <C-R><C-R>=<SID>InsertWordFromAround(0)<CR>
"inoremap <silent> <C-G><C-Y> <C-R><C-R>=<SID>InsertWordFromAround(1)<CR>

inoremap <silent> <Plug>InsertFromBelow <C-R><C-R>=InsertFromAround#InsertToggleFromAround(0,0)<CR>
inoremap <silent> <Plug>InsertFromAbove <C-R><C-R>=InsertFromAround#InsertToggleFromAround(1,0)<CR>
inoremap <silent> <C-G><C-E> <C-R><C-R>=InsertFromAround#InsertToggleFromAround(0,1)<CR>
inoremap <silent> <C-G><C-Y> <C-R><C-R>=InsertFromAround#InsertToggleFromAround(1,1)<CR>


inoremap <silent> <C-g><C-u> <C-r><C-o>=InsertFromAround#InsertIndentFromAround()<CR>

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
