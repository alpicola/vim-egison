" Vim indent file
" Language:	Egison
" Maintainer:	alpicola <ryo@alpico.la>
" Last Change:	2012 Dec 27

if exists("b:did_indent")
        finish
endif
let b:did_indent = 1

let s:save_cpo = &cpo
set cpo&vim

setlocal noautoindent
setlocal nosmartindent
setlocal expandtab
setlocal softtabstop=2
setlocal shiftwidth=2

setlocal indentexpr=GetEgisonIndent()
setlocal indentkeys=!^F,o,O

let b:undo_indent = "setlocal ai< si< et< ts< sts< sw< inde< indk<"

function! s:SearchParens(open, close, stopline)
    let pos = searchpairpos(a:open, '', a:close, 'bWn',
                \ 'synIDattr(synID(line("."), col("."), 0), "name") =~ "Comment"',
                \ a:stopline)
    return [pos[0], virtcol(pos)]
endfunction

function! GetEgisonIndent()
    if line('.') == 1
        return 0
    endif

    let commentline =  matchend(getline(line('.') - 1), '^\s*;')
    if commentline > 0
        return commentline - 1
    endif

    let paren = s:SearchParens('(', ')', 0)
    let angle = s:SearchParens('<', '>', paren[0])

    let paren_taken = 1
    if angle[0] > paren[0] || angle[1] > paren[1]
        let paren = angle
        let paren_taken = 0
    endif

    let brace = s:SearchParens('{', '}', paren[0])
    let bracket = s:SearchParens('\[', '\]', brace[0])

    if (bracket[0] > brace[0] || bracket[1] > brace[1]) &&
     \ (bracket[0] > paren[0] || bracket[1] > paren[1])
        return bracket[1]
    endif
     if brace[0] > paren[0] || brace[1] > paren[1]
        return brace[1]
    endif

    if paren == [0, 0]
        return 0
    endif

    call cursor(paren)

    normal! l
    if getline('.')[col('.') - 1] == ' '
        normal! w
    endif

    if paren_taken
        if getline('.')[col('.') - 1] =~ '[([{<]'
            return paren[1]
        endif
        let word = matchstr(getline('.'), '^\k\+', col('.') - 1)
        if &lispwords =~ '\<' . word . '\>'
            return paren[1] + &shiftwidth - 1
        endif
    endif

    normal! w
    if line('.') > paren[0] ||
     \ synIDattr(synID(line('.'), col('.'), 0), 'name') =~ 'Comment'
        return paren[1] + &shiftwidth - 1
    endif

    normal! ge
    return virtcol('.') + 1
endfunction

let &cpo = s:save_cpo
