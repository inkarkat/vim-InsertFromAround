" InsertFromAround.vim: Insert-mode mappings to fetch text or indent from surrounding lines.
"
" DEPENDENCIES:
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

function! s:RecordColumn()
    let s:previousCol = virtcol('.')
    let s:isAtEndOfLine = (col('.') == col('$'))
    return ''
endfunction
function! s:IndentNewLine()
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
inoremap <expr> <SID>RecordColumn <SID>RecordColumn()
inoremap <expr> <SID>IndentToColumn <SID>IndentToColumn()
inoremap <silent> <script> <S-CR> <SID>RecordColumn$<Left><CR><Esc>:call <SID>IndentNewLine()<CR>
" This will repeat the <Enter> or just the text entered after the mapping (if
" done) on "." in normal mode.

function! s:SearchNextVisible( lnum, pattern, direction )
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
function! s:InsertFromAround( isAbove, insertPattern )
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
    let l:targetLine = s:SearchNextVisible(line('.'), l:currentColumnExpr, (a:isAbove ? -1 : 1))

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
" Now using toggling, see below.
"inoremap <silent> <Plug>InsertFromBelow <C-R><C-R>=<SID>InsertFromAround(0,'.')<CR>
"inoremap <silent> <Plug>InsertFromAbove <C-R><C-R>=<SID>InsertFromAround(1,'.')<CR>
" Additionally overloaded with "Inline Completion" and moved to ingocompletion.vim.
"imap <expr> <C-E> pumvisible() ? '<C-E>' : '<Plug>InsertFromBelow'
"imap <expr> <C-Y> pumvisible() ? '<C-Y>' : '<Plug>InsertFromAbove'

function! s:InsertWordFromAround( isAbove )
    return s:InsertFromAround(a:isAbove, '.\{-}\%(\k\+\|\ze\s\|$\)')
endfunction
" Now using toggling, see below.
"inoremap <silent> <C-G><C-E> <C-R><C-R>=<SID>InsertWordFromAround(0)<CR>
"inoremap <silent> <C-G><C-Y> <C-R><C-R>=<SID>InsertWordFromAround(1)<CR>

function! s:InsertToggleFromAround( isAbove, isToggle )
    if ! exists('b:lastInsertFromAroundInsertLine') || b:lastInsertFromAroundInsertLine != line('.')
	let b:lastInsertFromAroundIsCharacterInsert = 1
    endif
    if a:isToggle
	let b:lastInsertFromAroundIsCharacterInsert = ! b:lastInsertFromAroundIsCharacterInsert
    endif
    return (b:lastInsertFromAroundIsCharacterInsert ? s:InsertFromAround(a:isAbove, '.') : s:InsertWordFromAround(a:isAbove))
endfunction
inoremap <silent> <Plug>InsertFromBelow <C-R><C-R>=<SID>InsertToggleFromAround(0,0)<CR>
inoremap <silent> <Plug>InsertFromAbove <C-R><C-R>=<SID>InsertToggleFromAround(1,0)<CR>
inoremap <silent> <C-G><C-E> <C-R><C-R>=<SID>InsertToggleFromAround(0,1)<CR>
inoremap <silent> <C-G><C-Y> <C-R><C-R>=<SID>InsertToggleFromAround(1,1)<CR>


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
function! s:InsertIndentFromAround()
    if exists('s:altIndentFromAround') && s:altIndentFromAround.lnum == line('.')
	let l:indent = s:altIndentFromAround.indent
	unlet s:altIndentFromAround
	return s:DeltaIndent(l:indent)
    endif

    let l:currentColumnExpr  = '^\s\+\%>' . virtcol('.') . 'v'
    let l:targetLineAbove = s:SearchNextVisible(line('.'), l:currentColumnExpr, -1)
    let l:targetLineBelow = s:SearchNextVisible(line('.'), l:currentColumnExpr,  1)
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
inoremap <silent> <C-g><C-u> <C-r><C-o>=<SID>InsertIndentFromAround()<CR>

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
