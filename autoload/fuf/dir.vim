"=============================================================================
" Copyright (c) 2007-2009 Takeshi NISHIDA
"
"=============================================================================
" LOAD GUARD {{{1

if exists('g:loaded_autoload_fuf_dir') || v:version < 702
  finish
endif
let g:loaded_autoload_fuf_dir = 1

" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

"
function fuf#dir#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function fuf#dir#renewCache()
  let s:cache = {}
endfunction

"
function fuf#dir#requiresOnCommandPre()
  return 0
endfunction

"
function fuf#dir#onInit()
  call fuf#defineLaunchCommand('FufDir'                    , s:MODE_NAME, '""')
  call fuf#defineLaunchCommand('FufDirWithFullCwd'         , s:MODE_NAME, 'fnamemodify(getcwd(), '':p'')')
  call fuf#defineLaunchCommand('FufDirWithCurrentBufferDir', s:MODE_NAME, 'expand(''%:~:.'')[:-1-len(expand(''%:~:.:t''))]')
endfunction

" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

let s:MODE_NAME = expand('<sfile>:t:r')

"
function s:enumItems(dir)
  let key = getcwd() . "\n" . a:dir
  if !exists('s:cache[key]')
    let s:cache[key] = fuf#enumExpandedDirsEntries(a:dir, g:fuf_dir_exclude)
    call filter(s:cache[key], 'v:val.word =~ ''[/\\]$''')
    if isdirectory(a:dir)
      call insert(s:cache[key], fuf#makePathItem(a:dir . '.', 0))
    endif
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
  return g:fuf_dir_prompt
endfunction

"
function s:handler.getPromptHighlight()
  return g:fuf_dir_promptHighlight
endfunction

"
function s:handler.targetsPath()
  return 1
endfunction

"
function s:handler.onComplete(patternSet)
  return fuf#filterMatchesAndMapToSetRanks(
        \ s:enumItems(a:patternSet.rawHead), a:patternSet,
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
