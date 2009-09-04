"=============================================================================
" Copyright (c) 2007-2009 Takeshi NISHIDA
"
"=============================================================================
" LOAD GUARD {{{1

if exists('g:loaded_autoload_fuf_givendir') || v:version < 702
  finish
endif
let g:loaded_autoload_fuf_givendir = 1

" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

"
function fuf#givendir#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function fuf#givendir#renewCache()
endfunction

"
function fuf#givendir#requiresOnCommandPre()
  return 0
endfunction

"
function fuf#givendir#onInit()
endfunction

"
function fuf#givendir#launch(initialPattern, partialMatching, items)
  let s:items = map(copy(a:items), 'substitute(v:val, ''[/\\]\?$'', "", "")')
  let s:items = map(s:items, 'fuf#makePathItem(v:val, 0)')
  call fuf#mapToSetSerialIndex(s:items, 1)
  call fuf#mapToSetAbbrWithSnippedWordAsPath(s:items)
  call fuf#launch(s:MODE_NAME, a:initialPattern, a:partialMatching)
endfunction

" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

let s:MODE_NAME = expand('<sfile>:t:r')

" }}}1
"=============================================================================
" s:handler {{{1

let s:handler = {}

"
function s:handler.getModeName()
  return s:MODE_NAME
endfunction

"
function s:handler.getPrompt()
  return g:fuf_givendir_prompt
endfunction

"
function s:handler.getPromptHighlight()
  return g:fuf_givendir_promptHighlight
endfunction

"
function s:handler.targetsPath()
  return 1
endfunction

"
function s:handler.onComplete(patternSet)
  return fuf#filterMatchesAndMapToSetRanks(
        \ s:items, a:patternSet,
        \ self.getFilteredStats(a:patternSet.raw), self.targetsPath())
endfunction

"
function s:handler.onOpen(expr, mode)
  execute ':cd ' . fnameescape(a:expr)
endfunction

"
function s:handler.onModeEnterPre()
endfunction

"
function s:handler.onModeEnterPost()
endfunction

"
function s:handler.onModeLeavePost(opened)
endfunction

" }}}1
"=============================================================================
" vim: set fdm=marker:
