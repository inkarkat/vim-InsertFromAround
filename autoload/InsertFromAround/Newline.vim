" InsertFromAround/Newline.vim: New line with indent from previous line.
"
" DEPENDENCIES:
"
" Copyright: (C) 2009-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.11.003	12-Sep-2017	Make <C-CR> handle comment prefixes, not just
"				indent. Use s:previousCol instead of indent().
"   1.11.002	10-Feb-2017	Use ingo#cursor#StartInsert().
"   1.00.001	14-Apr-2013	file creation from ingomappings.vim

function! InsertFromAround#Newline#RecordPreviousColumn()
    let s:previousCol = virtcol('.')
    let s:isAtEndOfLine = (col('.') == col('$'))
    return ''
endfunction
function! InsertFromAround#Newline#RecordNewColumn()
    let s:newCol = virtcol('.')
    return ''
endfunction
function! InsertFromAround#Newline#Insert()
    " FIXME: virtcol-addressing breaks with ":set list" when 'listchars' does
    " not contain the "tab" option. In that case, a <Tab> character is displayed
    " as just ^I, and only occupies 2 display cells. This could be worked around
    " by temporarily messing with 'list' or 'listchars', but so far I don't
    " bother.
    let l:isIndentOrPrefixInNewLine = (s:newCol > 1)
    let l:indentCols = s:previousCol - s:newCol
    if l:indentCols > 0
	execute 'normal!' l:indentCols . (l:isIndentOrPrefixInNewLine ? 'a' : 'i') . " \<Esc>\<Right>"
	" Register . will contain the <Space> after this; unfortunately, we
	" cannot tweak the register to contain a more expected <CR>, but it's
	" probably isn't not that important, anyway.
	.retab!	" This keeps the cursor position.
    endif
    normal! "_x
"****D echomsg '****' s:isAtEndOfLine l:isIndentOrPrefixInNewLine l:indentCols
    call ingo#cursor#StartInsert(s:isAtEndOfLine)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
