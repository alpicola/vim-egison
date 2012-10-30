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

let b:undo_indent = "setlocal ai< si< et< sts< sw< inde< indk<"

function! SearchParens(open, close, stopline)
    let pos = searchpairpos(a:open, '', a:close, 'bWn',
                \ 'synIDattr(synID(line("."), col("."), 0), "name") !~ "Paren"',
                \ a:stopline)
    return [pos[0], virtcol(pos)]
endfunction

function! GetEgisonIndent()
    if line('.') == 1
        return 0
    endif

    let paren = SearchParens('(', ')', 0)
    let angle = SearchParens('<', '>', paren[0])

    let paren_taken = 1
    if angle[0] > paren[0] || angle[1] > paren[1]
        let paren = angle
        let paren_taken = 0
    endif

    let brace = SearchParens('{', '}', paren[0])
    let bracket = SearchParens('\[', '\]', brace[0])

    if (bracket[0] > brace[0] || bracket[1] > brace[1]) &&
     \ (bracket[0] > paren[0] || bracket[1] > paren[1])
        return bracket[1]
    end
     if (brace[0] > paren[0] || brace[1] > paren[1])
        return brace[1]
    end

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
        let w = matchstr(getline('.'), '^\k\+', col('.') - 1)
        if &lispwords =~ '\<' . w . '\>'
            return paren[1] + &shiftwidth - 1
        endif
    end

    normal! w
    if line('.') > paren[0] ||
     \ synIDattr(synID(line("."), col("."), 0), "name") =~ "Comment"
        return paren[1] + &shiftwidth - 1
    endif

    normal! ge
    return virtcol('.') + 1
endfunction

let &cpo = s:save_cpo
