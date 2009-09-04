"=============================================================================
" Copyright (c) 2007-2009 Takeshi NISHIDA
"
"=============================================================================
" LOAD GUARD {{{1

if exists('g:loaded_autoload_fuf_file') || v:version < 702
  finish
endif
let g:loaded_autoload_fuf_file = 1

" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

"
function fuf#file#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function fuf#file#renewCache()
  let s:cache = {}
endfunction

"
function fuf#file#requiresOnCommandPre()
  return 0
endfunction

"
function fuf#file#onInit()
  call fuf#defineLaunchCommand('FufFile'                    , s:MODE_NAME, '""')
  call fuf#defineLaunchCommand('FufFileWithFullCwd'         , s:MODE_NAME, 'fnamemodify(getcwd(), '':p'')')
  call fuf#defineLaunchCommand('FufFileWithCurrentBufferDir', s:MODE_NAME, 'expand(''%:~:.'')[:-1-len(expand(''%:~:.:t''))]')
endfunction

" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

let s:MODE_NAME = expand('<sfile>:t:r')

"
function s:enumItems(dir)
  let key = getcwd() . "\n" . a:dir
  if !exists('s:cache[key]')
    let s:cache[key] = fuf#enumExpandedDirsEntries(a:dir, g:fuf_file_exclude)
    call fuf#mapToSetSerialIndex(s:cache[key], 1)
    call fuf#mapToSetAbbrWithSnippedWordAsPath(s:cache[key])
  endif
  return s:cache[key]
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
  return g:fuf_file_prompt
endfunction

"
function s:handler.getPromptHighlight()
  return g:fuf_file_promptHighlight
endfunction

"
function s:handler.targetsPath()
  return 1
endfunction

"
function s:handler.onComplete(patternSet)
  let key = a:patternSet.rawHead . 'AVOIDING EMPTY KEY'
  if !exists('self.cache[key]')
    " NOTE: filtering should be done with 'bufnr("^" . v:val.word . "$") != self.bufNrPrev'.
    "       But it takes a lot of time!
    let bufName = bufname(self.bufNrPrev)
    let self.cache[key] = filter(copy(s:enumItems(a:patternSet.rawHead)),
          \                      'v:val.word != bufName')
  endif
  return fuf#filterMatchesAndMapToSetRanks(
        \ self.cache[key], a:patternSet,
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
  let self.cache = {}
endfunction

"
function s:handler.onModeLeavePost(opened)
endfunction

" }}}1
"=============================================================================
" vim: set fdm=marker:
