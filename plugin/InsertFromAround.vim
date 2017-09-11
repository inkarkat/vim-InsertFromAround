" InsertFromAround.vim: Insert mode mappings to fetch text or indent from surrounding lines.
"
" DEPENDENCIES:
"   - InsertFromAround/Align.vim autoload script
"   - InsertFromAround/Indent.vim autoload script
"   - InsertFromAround/Newline.vim autoload script
"   - InsertFromAround/Text.vim autoload script
"
" Copyright: (C) 2009-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.10.005	29-Jan-2014	Implement <C-g><C-v> mapping that aligns to the
"				current character found in adjacent lines.
"   1.00.004	23-Jan-2014	Define <Plug>-mappings for the remaining
"				hard-coded mappings.
"	003	02-Aug-2013	CHG: Remap <S-CR> to <C-CR>, as I need the
"				<S-CR> imap for a mapping consistent with normal
"				mode.
"	002	04-Jun-2013	FIX: <S-CR> mapping broken by incomplete
"				factoring out of <SID>(RecordColumn).
"	001	14-Apr-2013	file creation from ingomappings.vim

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_InsertFromAround') || (v:version < 700)
    finish
endif
let g:loaded_InsertFromAround = 1

inoremap <expr> <SID>(RecordColumn) InsertFromAround#Newline#RecordColumn()
inoremap <silent> <script> <Plug>(InsertFromEnterAndIndent) <SID>(RecordColumn)$<Left><CR><Esc>:call InsertFromAround#Newline#Insert()<CR>
" This will repeat the <Enter> or just the text entered after the mapping (if
" done) on "." in normal mode.
if ! hasmapto('<Plug>(InsertFromEnterAndIndent)', 'i')
    imap <C-CR> <Plug>(InsertFromEnterAndIndent)
endif



inoremap <silent> <Plug>(InsertFromTextBelow) <C-r><C-r>=InsertFromAround#Text#Toggled(0,0)<CR>
inoremap <silent> <Plug>(InsertFromTextAbove) <C-r><C-r>=InsertFromAround#Text#Toggled(1,0)<CR>
if ! hasmapto('<Plug>(InsertFromTextBelow)', 'i')
    imap <C-e> <Plug>(InsertFromTextBelow)
endif
if ! hasmapto('<Plug>(InsertFromTextAbove)', 'i')
    imap <C-y> <Plug>(InsertFromTextAbove)
endif

inoremap <silent> <Plug>(InsertFromTextBelowToggle) <C-r><C-r>=InsertFromAround#Text#Toggled(0,1)<CR>
inoremap <silent> <Plug>(InsertFromTextAboveToggle) <C-r><C-r>=InsertFromAround#Text#Toggled(1,1)<CR>
if ! hasmapto('<Plug>(InsertFromTextBelowToggle)', 'i')
    imap <C-g><C-e> <Plug>(InsertFromTextBelowToggle)
endif
if ! hasmapto('<Plug>(InsertFromTextAboveToggle)', 'i')
    imap <C-g><C-y> <Plug>(InsertFromTextAboveToggle)
endif



inoremap <silent> <Plug>(InsertFromIndent) <C-r><C-o>=InsertFromAround#Indent#Insert()<CR>
if ! hasmapto('<Plug>(InsertFromIndent)', 'i')
    imap <C-g><C-u> <Plug>(InsertFromIndent)
endif



inoremap <silent> <Plug>(InsertFromAlignToPrevious) <C-r>=InsertFromAround#Align#ToPrevious()<CR>
if ! hasmapto('<Plug>(InsertFromAlignToPrevious)', 'i')
    imap <C-g><C-d> <Plug>(InsertFromAlignToPrevious)
endif
inoremap <silent> <Plug>(InsertFromAlignToNext) <C-r>=InsertFromAround#Align#ToNext()<CR>
if ! hasmapto('<Plug>(InsertFromAlignToNext)', 'i')
    imap <C-g><C-t> <Plug>(InsertFromAlignToNext)
endif

inoremap <silent> <Plug>(InsertFromAlignToCurrentChar) <C-r>=InsertFromAround#Align#ToCurrentChar()<CR>
if ! hasmapto('<Plug>(InsertFromAlignToCurrentChar)', 'i')
    imap <C-g><C-v> <Plug>(InsertFromAlignToCurrentChar)
endif
inoremap <silent> <Plug>(InsertFromAlignToQueriedChar) <C-r>=InsertFromAround#Align#ToQueriedChar()<CR>
if ! hasmapto('<Plug>(InsertFromAlignToQueriedChar)', 'i')
    imap <C-g>V <Plug>(InsertFromAlignToQueriedChar)
endif


" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
