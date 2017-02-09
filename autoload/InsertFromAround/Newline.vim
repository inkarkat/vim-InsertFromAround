" InsertFromAround/Newline.vim: New line with indent from previous line.
"
" DEPENDENCIES:
"
" Copyright: (C) 2009-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.00.001	14-Apr-2013	file creation from ingomappings.vim

function! InsertFromAround#Newline#RecordColumn()
    let s:previousCol = virtcol('.')
    let s:isAtEndOfLine = (col('.') == col('$'))
    return ''
endfunction
function! InsertFromAround#Newline#Insert()
    " FIXME: virtcol-addressing breaks with ":set list" when 'listchars' does
    " not contain the "tab" option. In that case, a <Tab> character is displayed
    " as just ^I, and only occupies 2 display cells. This could be worked around
    " by temporarily messing with 'list' or 'listchars', but so far I don't
    " bother.
    let l:isIndentInNewLine = (indent('.') > 0)
    let l:indentCols = s:previousCol - virtcol('.') - l:isIndentInNewLine
    if l:indentCols > 0
	execute 'normal!' l:indentCols . (l:isIndentInNewLine ? 'a' : 'i') . " \<Esc>\<Right>"
	" Register . will contain the <Space> after this; unfortunately, we
	" cannot tweak the register to contain a more expected <CR>, but it's
	" probably isn't not that important, anyway.
	.retab!	" This keeps the cursor position.
    endif
    normal! "_x
"****D echomsg '****' s:isAtEndOfLine l:isIndentInNewLine l:indentCols
    if s:isAtEndOfLine
	startinsert!
    else
	startinsert
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
