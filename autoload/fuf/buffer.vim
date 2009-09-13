"=============================================================================
" Copyright (c) 2007-2009 Takeshi NISHIDA
"
"=============================================================================
" LOAD GUARD {{{1

if exists('g:loaded_autoload_fuf_buffer') || v:version < 702
  finish
endif
let g:loaded_autoload_fuf_buffer = 1

" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

"
function fuf#buffer#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function fuf#buffer#getSwitchOrder()
  return g:fuf_buffer_switchOrder
endfunction

"
function fuf#buffer#renewCache()
endfunction

"
function fuf#buffer#requiresOnCommandPre()
  return 0
endfunction

"
function fuf#buffer#onInit()
  call fuf#defineLaunchCommand('FufBuffer', s:MODE_NAME, '""')
  augroup fuf#buffer
    autocmd!
    autocmd BufEnter     * call s:updateBufTimes()
    autocmd BufWritePost * call s:updateBufTimes()
  augroup END
endfunction

" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

let s:MODE_NAME = expand('<sfile>:t:r')

let s:bufTimes = {}

"
function s:updateBufTimes()
  let s:bufTimes[bufnr('%')] = localtime()
endfunction

"
function s:makeItem(nr)
  let item = fuf#makePathItem((empty(bufname(a:nr)) ? '[No Name]' : fnamemodify(bufname(a:nr), ':~:.')), 0)
  let item.index = a:nr
  let item.bufNr = a:nr
  let item.abbrPrefix = s:getBufIndicator(a:nr) . ' '
  let item.time = (exists('s:bufTimes[a:nr]') ? s:bufTimes[a:nr] : 0)
  call fuf#setMenuWithFormattedTime(item)
  return item
endfunction

"
function s:getBufIndicator(bufNr)
  if !getbufvar(a:bufNr, '&modifiable')
    return '[-]'
  elseif getbufvar(a:bufNr, '&modified')
    return '[+]'
  elseif getbufvar(a:bufNr, '&readonly')
    return '[R]'
  else
    return '   '
  endif
endfunction

"
function s:compareTimeDescending(i1, i2)
  return a:i1.time == a:i2.time ? 0 : a:i1.time > a:i2.time ? -1 : +1
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
  return g:fuf_buffer_prompt
endfunction

"
function s:handler.targetsPath()
  return 1
endfunction

"
function s:handler.onComplete(patternSet)
  return fuf#filterMatchesAndMapToSetRanks(
        \ self.items, a:patternSet,
        \ self.getFilteredStats(a:patternSet.raw), self.targetsPath())
endfunction

"
function s:handler.onOpen(expr, mode)
  " filter the selected item to get the buffer number for handling unnamed buffer
  call filter(self.items, 'v:val.word ==# a:expr')
  if !empty(self.items)
    call fuf#openBuffer(self.items[0].bufNr, a:mode, g:fuf_reuseWindow)
  endif
endfunction

"
function s:handler.onModeEnterPre()
endfunction

"
function s:handler.onModeEnterPost()
  let self.items = map(filter(range(1, bufnr('$')),
        \                     'buflisted(v:val) && v:val != self.bufNrPrev'),
        \              's:makeItem(v:val)')
  if g:fuf_buffer_mruOrder
    call fuf#mapToSetSerialIndex(sort(self.items, 's:compareTimeDescending'), 1)
  endif
  let self.items = fuf#mapToSetAbbrWithSnippedWordAsPath(self.items)
endfunction

"
function s:handler.onModeLeavePost(opened)
endfunction

" }}}1
"=============================================================================
" vim: set fdm=marker:
