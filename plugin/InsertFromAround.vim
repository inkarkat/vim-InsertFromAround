" InsertFromAround.vim: Insert mode mappings to fetch text or indent from surrounding lines.
"
" DEPENDENCIES:
"   - InsertFromAround/Align.vim autoload script
"   - InsertFromAround/Indent.vim autoload script
"   - InsertFromAround/Newline.vim autoload script
"   - InsertFromAround/Text.vim autoload script
"
" Copyright: (C) 2009-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_InsertFromAround') || (v:version < 700)
    finish
endif
let g:loaded_InsertFromAround = 1

inoremap <expr> <SID>(RecordPreviousColumn) InsertFromAround#Newline#RecordPreviousColumn()
inoremap <expr> <SID>(RecordNewColumn) InsertFromAround#Newline#RecordNewColumn()
inoremap <silent> <script> <Plug>(InsertFromEnterAndIndent) <SID>(RecordPreviousColumn)$<Left><CR><SID>(RecordNewColumn)<Esc>:call InsertFromAround#Newline#Insert()<CR>
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
    imap <C-g><C-b> <Plug>(InsertFromAlignToPrevious)
endif
inoremap <silent> <Plug>(InsertFromAlignToNext) <C-r>=InsertFromAround#Align#ToNext()<CR>
if ! hasmapto('<Plug>(InsertFromAlignToNext)', 'i')
    imap <C-g><C-a> <Plug>(InsertFromAlignToNext)
endif

nnoremap <silent> <Plug>(InsertFromAlignToPrevious)
\ :<C-u>let g:InsertFromAround#count = v:count<Bar>
\call InsertFromAround#Align#GoToFirstNonBlank()<Bar>
\execute 'normal i' . repeat("\<lt>Plug>(InsertFromAlignToPrevious)", v:count1) . "\<lt>C-\>\<lt>C-n>l"<Bar>
\silent! call repeat#set("\<lt>Plug>(InsertFromAlignToPrevious)", g:InsertFromAround#count)<CR>
nnoremap <silent> <Plug>(InsertFromAlignToNext)
\ :<C-u>let g:InsertFromAround#count = v:count<Bar>
\call InsertFromAround#Align#GoToFirstNonBlank()<Bar>
\execute 'normal i' . repeat("\<lt>Plug>(InsertFromAlignToNext)", v:count1) . "\<lt>C-\>\<lt>C-n>l"<Bar>
\silent! call repeat#set("\<lt>Plug>(InsertFromAlignToNext)", g:InsertFromAround#count)<CR>
if ! hasmapto('<Plug>(InsertFromAlignToPrevious)', 'n')
    nmap <b <Plug>(InsertFromAlignToPrevious)
endif
if ! hasmapto('<Plug>(InsertFromAlignToNext)', 'n')
    nmap >a <Plug>(InsertFromAlignToNext)
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
