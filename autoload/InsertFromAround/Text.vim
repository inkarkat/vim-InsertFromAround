" InsertFromAround/Text.vim: Fetch text from surrounding lines.
"
" DEPENDENCIES:
"   - InsertFromAround.vim autoload script
"   - ingo/mbyte/virtcol.vim autoload script
"
" Copyright: (C) 2009-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.00.001	14-Apr-2013	file creation from ingomappings.vim

function! s:TextFromAround( isAbove, insertPattern )
    " Locate a surrounding visible (i.e. not folded) line which is long enough
    " to have a character to copy into the current column. If the (<Tab> or
    " double-width) character begins at an earlier position and also occupies
    " the current column, insert that one, too.
    " To obtain the character, match one char between the largest virtual column
    " that is still smaller than the current column + 1 and the current column.
    " virtcol() returns the end virtual column for <Tab> or double-width
    " characters, but we need insertion to search for the beginning virtual
    " column. Thus, we cannot use virtcol('.') directly, and need to use a more
    " complicated algorithm.
    let l:startVirtCol = ingo#mbyte#virtcol#GetVirtStartColOfCurrentCharacter(line('.'), col('.'))
    if a:insertPattern ==# '.'
	let l:currentColumnExpr  = '\%<' . (l:startVirtCol + 1) . 'v.\%>' . l:startVirtCol . 'v'
    else
	let l:currentColumnExpr  = '.\%>' . l:startVirtCol . 'v' . a:insertPattern
    endif
    let l:targetLine = InsertFromAround#SearchNextVisible(line('.'), l:currentColumnExpr, (a:isAbove ? -1 : 1))

    let l:insertChar = ''
    if l:targetLine > 0
	if exists('b:lastInsertFromAroundInsertLine') && b:lastInsertFromAroundInsertLine == line('.') &&
	\   exists('b:lastInsertFromAroundIsAbove') && b:lastInsertFromAroundIsAbove == a:isAbove &&
	\   exists('b:lastInsertFromAroundVirtcol') && b:lastInsertFromAroundVirtcol < l:startVirtCol &&
	\   exists('b:lastInsertFromAroundTargetLine') && b:lastInsertFromAroundTargetLine != l:targetLine
	    " We're repeating an insert-from-around here: Line and insert
	    " direction are the same as the last time and the virtual column is
	    " to the right of the last insert.
	    " The previous target line has been exhausted; future inserts will
	    " be from a different line; thus, beep once.
	    unlet b:lastInsertFromAroundTargetLine
	else
	    " Return vertically copied character.
	    let b:lastInsertFromAroundTargetLine = l:targetLine
	    let l:insertChar = matchstr(getline(l:targetLine), l:currentColumnExpr)
	endif
	let b:lastInsertFromAroundInsertLine = line('.')
	let b:lastInsertFromAroundIsAbove = a:isAbove
	let b:lastInsertFromAroundVirtcol = l:startVirtCol
    "else
	" There is no such long line to copy from any more; beep.
    endif

    if l:insertChar == ''
	" No character to insert right now; signal this via a beep.
	call feedkeys("\<C-\>\<C-o>\<Esc>", 'n')
    endif

    return l:insertChar
endfunction

function! s:WordFromAround( isAbove )
    return s:TextFromAround(a:isAbove, '.\{-}\%(\k\+\|\ze\s\|$\)')
endfunction

function! InsertFromAround#Text#Toggled( isAbove, isToggle )
    if ! exists('b:lastInsertFromAroundInsertLine') || b:lastInsertFromAroundInsertLine != line('.')
	let b:lastInsertFromAroundIsCharacterInsert = 1
    endif
    if a:isToggle
	let b:lastInsertFromAroundIsCharacterInsert = ! b:lastInsertFromAroundIsCharacterInsert
    endif
    return (b:lastInsertFromAroundIsCharacterInsert ? s:TextFromAround(a:isAbove, '.') : s:WordFromAround(a:isAbove))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
