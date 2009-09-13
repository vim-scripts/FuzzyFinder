"=============================================================================
" Copyright (c) 2007-2009 Takeshi NISHIDA
"
"=============================================================================
" LOAD GUARD {{{1

if exists('g:loaded_autoload_fuf_givenfile') || v:version < 702
  finish
endif
let g:loaded_autoload_fuf_givenfile = 1

" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

"
function fuf#givenfile#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function fuf#givenfile#getSwitchOrder()
  return -1
endfunction

"
function fuf#givenfile#renewCache()
endfunction

"
function fuf#givenfile#requiresOnCommandPre()
  return 0
endfunction

"
function fuf#givenfile#onInit()
endfunction

"
function fuf#givenfile#launch(initialPattern, partialMatching, prompt, items)
  let s:prompt = (empty(a:prompt) ? '>' : a:prompt)
  let s:items = map(copy(a:items), 'fuf#makePathItem(v:val, 0)')
  call fuf#mapToSetSerialIndex(s:items, 1)
  call map(s:items, 'fuf#setAbbrWithFormattedWord(v:val)')
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
  return s:prompt
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
  call fuf#openFile(a:expr, a:mode, g:fuf_reuseWindow)
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
