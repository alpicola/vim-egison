if version < 600
  syntax clear
elseif exists('b:current_syntax')
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn match egisonNumber '\<-*\d\+\%(\.\d\+\)\?\>'
syn match egisonBoolean '#[tf]'

syn keyword egisonSyntax test define execute load load-file
syn keyword egisonSyntax lambda match match-all let letrec do if loop type macro

syn region egisonSexp matchgroup=egisonParen start='(' matchgroup=egisonParen end=')' contains=ALL
syn region egisonColl matchgroup=egisonParen start='{' matchgroup=egisonParen end='}' contains=ALL
syn region egisonTuple matchgroup=egisonParen start='\[' matchgroup=egisonParen end='\]' contains=ALL
syn region egisonPattern matchgroup=egisonParen start='<' matchgroup=egisonParen end='>' contains=ALL

syn match egisonIdentifier '\<\$[a-zA-Z_&*+-/:=][a-zA-Z_0-9&*+-/:=!?]*\>'

syn match egisonComment ';.*$'
syntax region schemeMultilineComment start='#|' end='|#' contains=egisonMultilineComment

if version >= 508 || !exists('did_actionscript_syn_inits')
  if version < 508
    let did_actionscript_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink egisonSyntax           Statement
  HiLink egisonFunction         Function

  HiLink egisonString           String
  HiLink egisonCharacter        Character
  HiLink egisonNumber           Number
  HiLink egisonBoolean          Boolean

  HiLink egisonParen            Delimiter
  HiLink egisonConstant         Constant
  HiLink egisonIdentifier       Identifier

  HiLink egisonComment          Comment
  HiLink egisonMultilineComment Comment

  delcommand HiLink
endif

let b:current_syntax = 'egison'

let &cpo = s:cpo_save
unlet s:cpo_save
