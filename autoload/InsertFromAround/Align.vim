" InsertFromAround/Align.vim: Align to text from previous line.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"
" Copyright: (C) 2013-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.00.001	23-Apr-2013	file creation

function! s:GetPreviousTextColumn( virtcol, isToNext )
    let l:lnum = ingo#folds#NextVisibleLine(line('.') - 1, -1)
    if l:lnum == -1
	return -1
    endif

    if a:isToNext
	let l:startOfTextExpr  = '^.\{-}\%>' . (a:virtcol - 1) . 'v\S*\s\+\S'
    else
	let l:startOfTextExpr  = '^.*\S*\s\+\%<' . a:virtcol . 'v\S'
    endif

    let l:text = matchstr(getline(l:lnum), l:startOfTextExpr)
    if empty(l:text) && a:isToNext
	" When there's no next text after the current column, align to the end
	" of the previous line.
	let l:text = getline(l:lnum) . ' '
    endif
"****D echomsg '****' string(l:startOfTextExpr) string(l:text)
    let l:alignVirtCol = ingo#compat#strdisplaywidth(l:text)

    if a:isToNext && l:alignVirtCol <= a:virtcol
	return -1
    endif
    return l:alignVirtCol
endfunction
function! InsertFromAround#Align#AlignToPrevious()
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
function! InsertFromAround#Align#AlignToNext()
    " Use i_CTRL-R to insert the indenting <Tab> characters as typed, so that
    " the indent settings apply and the added whitespace is fused with preceding
    " whitespace.
    let l:currentVirtCol = virtcol('.')
    let l:alignVirtCol = s:GetPreviousTextColumn(l:currentVirtCol, 1)
    if l:alignVirtCol == -1
	return "\<C-\>\<C-o>\<Esc>" " Beep.
    endif

    let l:insertColumns = l:alignVirtCol - l:currentVirtCol
"****D echomsg '**** align' l:currentVirtCol 'to' l:alignVirtCol ':' l:insertColumns
    return s:RenderColumns(l:currentVirtCol, l:insertColumns)
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

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
