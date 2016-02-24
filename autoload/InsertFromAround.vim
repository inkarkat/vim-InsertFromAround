" InsertFromAround.vim: Insert mode mappings to fetch text or indent from surrounding lines.
"
" DEPENDENCIES:
"   - ingo/folds.vim autoload script
"
" Copyright: (C) 2009-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.00.001	14-Apr-2013	file creation from ingomappings.vim

function! InsertFromAround#SearchNextVisible( lnum, pattern, direction )
    let l:lnum = a:lnum
    while l:lnum > 0 && l:lnum <= line('$')
	let l:lnum = ingo#folds#NextVisibleLine(l:lnum + a:direction, a:direction)
	if l:lnum == -1
	    return -1
	endif

	if match(getline(l:lnum), a:pattern) != -1
	    return l:lnum
	endif
    endwhile

    return -1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
