" InsertFromAround/Align.vim: Align to text from previous line.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"   - ingo/query/get.vim autoload script
"
" Copyright: (C) 2013-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.10.003	30-Jan-2014	Implement alignment to queried character.
"				FIX: Buffer bounds check in
"				s:FindClosestColumn() needs to consider the
"				a:direction, or it won't work when the current
"				line is at the opposite side.
"   1.10.002	29-Jan-2014	ENH: Also consider previous lines when the
"				closer lines are shorter than the cursor column.
"				Factor out s:AlignToNext().
"				Implement alignment to current character via
"				InsertFromAround#Align#ToCurrentChar() and
"				s:GetClosestCharTextColumn().
"   1.00.001	23-Apr-2013	file creation

function! s:AlignToNext( baseVirtCol, TargetColumnFuncref, ... )
    " Use i_CTRL-R to insert the indenting <Tab> characters as typed, so that
    " the indent settings apply and the added whitespace is fused with preceding
    " whitespace.
    let l:alignVirtCol = call(a:TargetColumnFuncref, [a:baseVirtCol] + a:000)
    if l:alignVirtCol == -1
	return "\<C-\>\<C-o>\<Esc>" " Beep.
    endif

    let l:insertColumns = l:alignVirtCol - a:baseVirtCol
"****D echomsg '**** align' a:baseVirtCol 'to' l:alignVirtCol ':' l:insertColumns
    return s:RenderColumns(virtcol('.'), l:insertColumns)
endfunction
function! s:RenderColumns( virtcol, columnNum )
    if &expandtab
	return repeat(' ', a:columnNum)
    endif

    let l:tabWidth = (&softtabstop > 0 ? &softtabstop : &tabstop)
    let l:renderedColumns = ''
    let l:renderedColumnCnt = 0
    let l:tabColumns = l:tabWidth - (a:virtcol - 1) % l:tabWidth
    if l:tabColumns <= a:columnNum
	let l:renderedColumns .= "\t"
	let l:renderedColumnCnt += l:tabColumns
    endif

    let l:fullTabNum = (a:columnNum - l:renderedColumnCnt) / l:tabWidth
    let l:renderedColumns .= repeat("\t", l:fullTabNum)
    let l:renderedColumnCnt += l:tabWidth * l:fullTabNum

    let l:renderedColumns .= repeat(' ', a:columnNum - l:renderedColumnCnt)

    return l:renderedColumns
endfunction

function! s:GetPreviousTextColumn( virtcol, isToNext )
    if a:isToNext
	let l:startOfTextExpr  = '^.\{-}\%>' . (a:virtcol - 1) . 'v\S*\s\+\S'
    else
	let l:startOfTextExpr  = '^.*\S*\s\+\%<' . a:virtcol . 'v\S'
    endif

    let l:lnum = line('.')
    while l:lnum > 1
	let l:lnum = ingo#folds#NextVisibleLine(l:lnum - 1, -1)
	if l:lnum == -1
	    return -1
	endif

	let l:text = matchstr(getline(l:lnum), l:startOfTextExpr)
	if empty(l:text)
	    if a:isToNext
		" When there's no next text after the current column, align to
		" the end of the previous line.
		let l:text = getline(l:lnum) . ' '
	    else
		continue    " No match in this line; try preceding line(s).
	    endif
	endif
"****D echomsg '****' string(l:startOfTextExpr) string(l:text)
	let l:alignVirtCol = ingo#compat#strdisplaywidth(l:text)

	if a:isToNext && l:alignVirtCol <= a:virtcol
	    continue    " Too short; try preceding line(s).
	endif
	return l:alignVirtCol
    endwhile

    return -1   " No match in any preceding line.
endfunction


function! InsertFromAround#Align#ToPrevious()
    " For dedenting, we directly manipulate the line with setline(), and only
    " possibly return typed characters to cause a beep.
    let l:currentVirtCol = virtcol('.')
    let l:alignVirtCol = s:GetPreviousTextColumn(l:currentVirtCol, 0)
    if l:alignVirtCol == -1
	return "\<C-\>\<C-o>\<Esc>" " Beep.
    endif

    let l:deleteColumns = l:currentVirtCol - l:alignVirtCol
"****D echomsg '**** align' l:currentVirtCol 'to' l:alignVirtCol ':' l:deleteColumns
    let l:line = getline('.')
    let l:beforeAlign = matchstr(l:line, '^.*\%<' . (l:alignVirtCol + 1) . 'v')
    let l:afterCursor  = matchstr(l:line, '\%>' . (l:currentVirtCol - 1) . 'v.*')
    let l:removed = strpart(l:line, len(l:beforeAlign), len(l:line) - len(l:beforeAlign) - len(l:afterCursor))
    if l:removed =~# '^\s*$'
	let l:padding = repeat(' ', l:alignVirtCol - 1 - ingo#compat#strdisplaywidth(l:beforeAlign))
	let l:beforeCursor = l:beforeAlign . l:padding
    else
	" There is text between the align position and the cursor. Remove as
	" much whitespace from the end as possible, but do not remove any text.
	let l:remainder = substitute(l:removed, '\s\+$', '', '')
	if l:remainder ==# l:removed
	    " Beep when nothing could be removed.
	    return "\<C-\>\<C-o>\<Esc>" " Beep.
	endif
	let l:beforeCursor = l:beforeAlign . l:remainder
    endif

    let l:replacedLine = l:beforeCursor . l:afterCursor
    call setline('.', l:replacedLine)
    call cursor(0, len(l:beforeCursor) + 1)
    return ''
endfunction
function! InsertFromAround#Align#ToNext()
    return s:AlignToNext(virtcol('.'), function('s:GetPreviousTextColumn'), 1)
endfunction

function! s:FindClosestColumn( virtcol, expr, direction )
    let l:lnum = line('.')
    while a:direction == -1 && l:lnum > 1 || a:direction == 1 && l:lnum < line('$')
	let l:lnum = ingo#folds#NextVisibleLine(l:lnum + a:direction, a:direction)
	if l:lnum == -1
	    return -1
	endif

	let l:text = matchstr(getline(l:lnum), a:expr)
	if empty(l:text)
	    continue    " No match in this line; try preceding line(s).
	endif

	let l:alignVirtCol = ingo#compat#strdisplaywidth(l:text)
	if l:alignVirtCol <= a:virtcol
	    continue    " Too short; try preceding line(s).
	endif
	return l:alignVirtCol
    endwhile

    return -1   " No match in any preceding line.
endfunction
function! s:GetClosestCharTextColumn( virtcol, char )
    let l:startOfCharExpr = '\V\C\^\.\{-}\%>'  . a:virtcol . 'v' . escape(a:char, '\')
    let l:prevVirtCol = s:FindClosestColumn(a:virtcol, l:startOfCharExpr, -1)
    let l:nextVirtCol = s:FindClosestColumn(a:virtcol, l:startOfCharExpr, +1)

    let l:closestVirtCol = min(filter([l:prevVirtCol, l:nextVirtCol], 'v:val != -1'))
    return (l:closestVirtCol > 0 ? l:closestVirtCol : -1)
endfunction
function! InsertFromAround#Align#ToCurrentChar()
    let l:char = matchstr(getline('.'), '\%>' . (col('.') - 1) . 'c\S')
    if empty(l:char)
	" No non-whitespace character after the cursor.
	return "\<C-\>\<C-o>\<Esc>" " Beep.
    endif
    return s:AlignToNext(virtcol('.'), function('s:GetClosestCharTextColumn'), l:char)
endfunction

function! InsertFromAround#Align#ToQueriedChar()
    let l:char = ingo#query#get#Char()
    if empty(l:char) | return '' | endif

    let l:baseCol = searchpos('\V\C' . escape(l:char, '\'), 'nW', line('.'))[1]
    if l:baseCol == 0
	" No match of the queried character after the cursor.
	return "\<C-\>\<C-o>\<Esc>" " Beep.
    endif

    let l:baseVirtCol = ingo#compat#strdisplaywidth(strpart(getline('.'), 0, l:baseCol - 1)) + 1 " Do not include the searched character in the width calculation, and instead add one. This gives the correct start column when the matched character has a width of multiple screen cells.
    return s:AlignToNext(l:baseVirtCol, function('s:GetClosestCharTextColumn'), l:char)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
