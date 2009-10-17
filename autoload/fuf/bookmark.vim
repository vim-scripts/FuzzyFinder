"=============================================================================
" Copyright (c) 2007-2009 Takeshi NISHIDA
"
"=============================================================================
" LOAD GUARD {{{1

if exists('g:loaded_autoload_fuf_bookmark') || v:version < 702
  finish
endif
let g:loaded_autoload_fuf_bookmark = 1

" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

"
function fuf#bookmark#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function fuf#bookmark#getSwitchOrder()
  return g:fuf_bookmark_switchOrder
endfunction

"
function fuf#bookmark#renewCache()
endfunction

"
function fuf#bookmark#requiresOnCommandPre()
  return 0
endfunction

"
function fuf#bookmark#onInit()
  call fuf#defineLaunchCommand('FufBookmark', s:MODE_NAME, '""')
  command! -bang -narg=?        FufAddBookmark               call s:bookmarkHere(<q-args>)
  command! -bang -narg=0 -range FufAddBookmarkAsSelectedText call s:bookmarkHere(s:getSelectedText())
endfunction

" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

let s:MODE_NAME = expand('<sfile>:t:r')
let s:OPEN_TYPE_DELETE = -1

"
function s:getSelectedText()
  let regUN = [@", getregtype('"')]
  let reg0  = [@0, getregtype('0')]
  if mode() =~# "[vV\<C-v>]"
    silent normal! ygv
  else
    let pos = getpos('.')
    silent normal! gvy
    call setpos('.', pos)
  endif
  let text = @"
  call setreg('"', regUN[0], regUN[1])
  call setreg('0', reg0[0], reg0[1])
  return text
endfunction

" opens a:path and jumps to the line matching to a:pattern from a:lnum within
" a:range. if not found, jumps to a:lnum.
function s:jumpToBookmark(path, mode, pattern, lnum)
  call fuf#openFile(a:path, a:mode, g:fuf_reuseWindow)
  let ln = a:lnum
  for i in range(0, g:fuf_bookmark_searchRange)
    if a:lnum + i <= line('$') && getline(a:lnum + i) =~ a:pattern
      let ln += i
      break
    elseif a:lnum - i >= 1 && getline(a:lnum - i) =~ a:pattern
      let ln -= i
      break
    endif
  endfor
  call cursor(ln, 0)
  normal! zvzz
endfunction

"
function s:getLinePattern(lnum)
  return '\C\V\^' . escape(getline(a:lnum), '\') . '\$'
endfunction

"
function s:bookmarkHere(word)
  if !empty(&buftype) || expand('%') !~ '\S'
    call fuf#echoWithHl('Can''t bookmark this buffer.', 'WarningMsg')
    return
  endif
  let item = {
        \   'word' : (a:word =~ '\S' ? substitute(a:word, '\n', ' ', 'g')
        \                            : pathshorten(expand('%:p:~')) . '|' . line('.') . '| ' . getline('.')),
        \   'path' : expand('%:p'),
        \   'lnum' : line('.'),
        \   'pattern' : s:getLinePattern(line('.')),
        \   'time' : localtime(),
        \ }
  let item.word = fuf#inputHl('Bookmark as:', item.word, 'Question')
  if item.word !~ '\S'
    call fuf#echoWithHl('Canceled', 'WarningMsg')
    return
  endif
  let info = fuf#loadInfoFile(s:MODE_NAME)
  call insert(info.data, item)
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
  return g:fuf_bookmark_prompt
endfunction

"
function s:handler.targetsPath()
  return 0
endfunction

"
function s:handler.onComplete(patternSet)
  return fuf#filterMatchesAndMapToSetRanks(
        \ self.items, a:patternSet, self.getFilteredStats(a:patternSet.raw))
endfunction

"
function s:handler.onOpen(expr, mode)
  if a:mode == s:OPEN_TYPE_DELETE
    call filter(self.info.data, 'v:val.word !=# a:expr')
    call fuf#saveInfoFile(s:MODE_NAME, self.info)
    call fuf#launch(s:MODE_NAME, self.lastPattern, self.partialMatching)
    return
  elseif
    for item in self.info.data
      if item.word ==# a:expr
        call s:jumpToBookmark(item.path, a:mode, item.pattern, item.lnum)
        break
      endif
    endfor
  endif
endfunction

"
function s:handler.onModeEnterPre()
endfunction

"
function s:handler.onModeEnterPost()
  call fuf#defineKeyMappingInHandler(g:fuf_bookmark_keyDelete,
        \                            'onCr(' . s:OPEN_TYPE_DELETE . ', 0)')
  let self.items = copy(self.info.data)
  call map(self.items, 'fuf#makeNonPathItem(v:val.word, strftime(g:fuf_timeFormat, v:val.time))')
  call fuf#mapToSetSerialIndex(self.items, 1)
  call map(self.items, 'fuf#setAbbrWithFormattedWord(v:val)')
endfunction

"
function s:handler.onModeLeavePost(opened)
endfunction

" }}}1
"=============================================================================
" vim: set fdm=marker:
