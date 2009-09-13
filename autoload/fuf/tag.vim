"=============================================================================
" Copyright (c) 2007-2009 Takeshi NISHIDA
"
"=============================================================================
" LOAD GUARD {{{1

if exists('g:loaded_autoload_fuf_tag') || v:version < 702
  finish
endif
let g:loaded_autoload_fuf_tag = 1

" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

"
function fuf#tag#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function fuf#tag#getSwitchOrder()
  return g:fuf_tag_switchOrder
endfunction

"
function fuf#tag#renewCache()
  let s:cache = {}
endfunction

"
function fuf#tag#requiresOnCommandPre()
  return 0
endfunction

"
function fuf#tag#onInit()
  call fuf#defineLaunchCommand('FufTag'              , s:MODE_NAME, '""')
  call fuf#defineLaunchCommand('FufTagWithCursorWord', s:MODE_NAME, 'expand(''<cword>'')')
endfunction

" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

let s:MODE_NAME = expand('<sfile>:t:r')

"
function s:enumTags(tagFiles)
  if !len(a:tagFiles)
    return []
  endif
  let key = join(a:tagFiles, "\n")
  " cache not created or tags file updated? 
  if !exists('s:cache[key]') || max(map(copy(a:tagFiles), 'getftime(v:val) >= s:cache[key].time'))
    let items = fuf#unique(fuf#concat(map(copy(a:tagFiles), 's:getTagList(v:val)')))
    let items = map(items, '{ "word" : v:val }')
    let items = map(items, 'fuf#setBoundariesWithWord(v:val)')
    call fuf#mapToSetSerialIndex(items, 1)
    let items = map(items, 'fuf#setAbbrWithFormattedWord(v:val)')
    let s:cache[key] = { 'time'  : localtime(), 'items' : items }
  endif
  return s:cache[key].items
endfunction

"
function s:getTagList(tagfile)
  let result = map(readfile(a:tagfile), 'matchstr(v:val, ''^[^!\t][^\t]*'')')
  return filter(result, 'v:val =~ ''\S''')
endfunction

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
  return g:fuf_tag_prompt
endfunction

"
function s:handler.targetsPath()
  return 0
endfunction

"
function s:handler.onComplete(patternSet)
  return fuf#filterMatchesAndMapToSetRanks(
        \ s:enumTags(self.tagFiles), a:patternSet,
        \ self.getFilteredStats(a:patternSet.raw), self.targetsPath())
endfunction

"
function s:handler.onOpen(expr, mode)
  call fuf#openTag(a:expr, a:mode)
endfunction

"
function s:handler.onModeEnterPre()
  let self.tagFiles = fuf#getCurrentTagFiles()
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
