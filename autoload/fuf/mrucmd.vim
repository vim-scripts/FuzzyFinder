"=============================================================================
" Copyright (c) 2007-2009 Takeshi NISHIDA
"
"=============================================================================
" LOAD GUARD {{{1

if exists('g:loaded_autoload_fuf_mrucmd') || v:version < 702
  finish
endif
let g:loaded_autoload_fuf_mrucmd = 1

" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

"
function fuf#mrucmd#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function fuf#mrucmd#getSwitchOrder()
  return g:fuf_mrucmd_switchOrder
endfunction

"
function fuf#mrucmd#renewCache()
endfunction

"
function fuf#mrucmd#requiresOnCommandPre()
  return 1
endfunction

"
function fuf#mrucmd#onInit()
  call fuf#defineLaunchCommand('FufMruCmd', s:MODE_NAME, '""')
endfunction

"
function fuf#mrucmd#onCommandPre(cmd)
  if getcmdtype() =~ '^[:/?]'
    call s:updateInfo(a:cmd)
  endif
endfunction


" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

let s:MODE_NAME = expand('<sfile>:t:r')

"
function s:updateInfo(cmd)
  let info = fuf#loadInfoFile(s:MODE_NAME)
  let info.data = fuf#updateMruList(
        \ info.data, { 'word' : a:cmd, 'time' : localtime() },
        \ g:fuf_mrucmd_maxItem, g:fuf_mrucmd_exclude)
  call fuf#saveInfoFile(s:MODE_NAME, info)
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
  return g:fuf_mrucmd_prompt
endfunction

"
function s:handler.targetsPath()
  return 0
endfunction

"
function s:handler.onComplete(patternSet)
  return fuf#filterMatchesAndMapToSetRanks(
        \ self.items, a:patternSet,
        \ self.getFilteredStats(a:patternSet.raw), self.targetsPath())
endfunction

"
function s:handler.onOpen(expr, mode)
  call s:updateInfo(a:expr)
  call histadd(a:expr[0], a:expr[1:])
  call feedkeys(a:expr . "\<CR>", 'n')
endfunction

"
function s:handler.onModeEnterPre()
endfunction

"
function s:handler.onModeEnterPost()
  let self.items = deepcopy(self.info.data)
  let self.items = map(self.items, 'fuf#setMenuWithFormattedTime(v:val)')
  let self.items = map(self.items, 'fuf#setBoundariesWithWord(v:val)')
  call fuf#mapToSetSerialIndex(self.items, 1)
  let self.items = map(self.items, 'fuf#setAbbrWithFormattedWord(v:val)')
endfunction

"
function s:handler.onModeLeavePost(opened)
endfunction

" }}}1
"=============================================================================
" vim: set fdm=marker:
