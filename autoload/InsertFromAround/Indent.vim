" InsertFromAround/Indent.vim: Fetch indent from surrounding lines.
"
" DEPENDENCIES:
"   - InsertFromAround.vim autoload script
"   - ingo/compat.vim autoload script
"
" Copyright: (C) 2009-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.00.002	07-May-2013	When there's only whitespace before the cursor,
"				replace it with the indent; instead of returning
"				the delta whitespace, this also correctly
"				handles the case when a <Tab> is appended to
"				existing spaces: The spaces should be dropped,
"				as they do not contribute to the indent.
"	001	14-Apr-2013	file creation from ingomappings.vim

function! s:SortByDisplayWidth( i1, i2 )
    let l:w1 = ingo#compat#strdisplaywidth(a:i1)
    let l:w2 = ingo#compat#strdisplaywidth(a:i2)
    return (l:w1 == l:w2 ? 0 : l:w1 > l:w2 ? 1 : -1)
endfunction
function! s:DeltaIndent( indent )
    let l:widthBeforeCursor = virtcol('.') - 1
    if l:widthBeforeCursor == 0
	return a:indent
    endif

    let l:beforeCursor = strpart(getline('.'), 0, col('.') - 1)
    if l:beforeCursor =~# '^\s\+'
	" There's only whitespace before the cursor. Replace it with the indent;
	" in contrast to returning the delta whitespace, this also correctly
	" handles the case when a <Tab> is appended to existing spaces: The
	" spaces should be dropped, as they do not contribute to the indent.
	call setline('.', a:indent . strpart(getline('.'), col('.') - 1))
	call cursor(0, len(a:indent) + 1)
	return ''
    endif

    let l:cnt = 1
    while 1
	let l:truncatedIndent = matchstr(a:indent, '^.\{' . l:cnt . '}')
	if ingo#compat#strdisplaywidth(l:truncatedIndent) > l:widthBeforeCursor
	    break
	endif
	let l:cnt += 1
    endwhile

    return matchstr(a:indent, '^.\{' . (l:cnt - 1) . '}\zs.*')
endfunction
function! InsertFromAround#Indent#Insert()
    if exists('s:altIndentFromAround') && s:altIndentFromAround.lnum == line('.')
	let l:indent = s:altIndentFromAround.indent
	unlet s:altIndentFromAround
	return s:DeltaIndent(l:indent)
    endif

    let l:currentColumnExpr  = '^\s\+\%>' . virtcol('.') . 'v'
    let l:targetLineAbove = InsertFromAround#SearchNextVisible(line('.'), l:currentColumnExpr, -1)
    let l:targetLineBelow = InsertFromAround#SearchNextVisible(line('.'), l:currentColumnExpr,  1)
    let l:indents =
    \   sort(
    \	    map(
    \		filter([l:targetLineAbove, l:targetLineBelow], 'v:val > 0'),
    \		'matchstr(getline(v:val), "^\\s\\+")'
    \	    ),
    \       's:SortByDisplayWidth'
    \   )
    if len(l:indents) > 0
	let l:indent = l:indents[0]
	if len(l:indents) > 1
	    let s:altIndentFromAround = {'lnum': line('.'), 'indent': l:indents[1]}
	endif
	return s:DeltaIndent(l:indent)
    else
	" FIXME: This moves the cursor one left when appending at the end of the
	" line.
	execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
	return ''
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
