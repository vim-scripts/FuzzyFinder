"=============================================================================
" Copyright (c) 2007-2010 Takeshi NISHIDA
"
"=============================================================================
" LOAD GUARD {{{1

if !l9#guardScriptLoading(expand('<sfile>:p'), 702, 100)
  finish
endif

" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

"
function fuf#mrufile#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function fuf#mrufile#getSwitchOrder()
  return g:fuf_mrufile_switchOrder
endfunction

"
function fuf#mrufile#getEditableDataNames()
  return ['items', 'itemdirs']
endfunction

"
function fuf#mrufile#renewCache()
  let s:cache = {}
  let s:aroundCache = {}
endfunction

"
function fuf#mrufile#requiresOnCommandPre()
  return 0
endfunction

"
function fuf#mrufile#onInit()
  call fuf#defineLaunchCommand('FufMruFile', s:MODE_NAME, '""')
  augroup fuf#mrufile
    autocmd!
    autocmd BufEnter     * call s:updateData()
    autocmd BufWritePost * call s:updateData()
  augroup END
endfunction

" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

let s:MODE_NAME = expand('<sfile>:t:r')
let s:OPEN_TYPE_EXPAND = -1

"
function s:updateData()
  if !empty(&buftype) || !filereadable(expand('%'))
    return
  endif
  let items = fuf#loadDataFile(s:MODE_NAME, 'items')
  let items = fuf#updateMruList(
        \ items, { 'word' : expand('%:p'), 'time' : localtime() },
        \ g:fuf_mrufile_maxItem, g:fuf_mrufile_exclude)
  call fuf#saveDataFile(s:MODE_NAME, 'items', items)
  call s:removeItemFromCache(expand('%:p'))
  let itemDirs = fuf#loadDataFile(s:MODE_NAME, 'itemdirs')
  let itemDirs = fuf#updateMruList(
        \ itemDirs, { 'word' : expand('%:p:h') },
        \ g:fuf_mrufile_maxItemDir, g:fuf_mrufile_exclude)
  call fuf#saveDataFile(s:MODE_NAME, 'itemdirs', itemDirs)
endfunction

"
function s:removeItemFromCache(word)
  for items in values(s:cache)
    if exists('items[a:word]')
      unlet items[a:word]
    endif
  endfor
endfunction

" returns empty value if invalid item
function s:formatItemUsingCache(item)
  if a:item.word !~ '\S'
    return {}
  endif
  if !exists('s:cache[a:item.word]')
    if filereadable(a:item.word)
      let s:cache[a:item.word] = fuf#makePathItem(
            \ fnamemodify(a:item.word, ':p:~'), strftime(g:fuf_timeFormat, a:item.time), 0)
    else
      let s:cache[a:item.word] = {}
    endif
  endif
  return s:cache[a:item.word]
endfunction

"
function s:expandSearchDir(dir, level)
  let dirs = [a:dir]
  let dirPrev = a:dir
  for i in range(a:level)
    let dirPrev = l9#concatPaths([dirPrev, '*'])
    call add(dirs, dirPrev)
  endfor
  let dirPrev = a:dir
  for i in range(a:level)
    let dirPrevPrev = dirPrev
    let dirPrev = fnamemodify(dirPrev, ':h')
    if dirPrevPrev ==# dirPrev
      break
    endif
    call add(dirs, dirPrev)
  endfor
  return dirs
endfunction

"
function s:listAroundFilesUsingCache(dir)
  if !exists('s:aroundCache[a:dir]')
    let s:aroundCache[a:dir] = [a:dir] +
          \              split(glob(a:dir . l9#getPathSeparator() . "*" ), "\n") +
          \              split(glob(a:dir . l9#getPathSeparator() . ".*"), "\n")
    call filter(s:aroundCache[a:dir], 'filereadable(v:val)')
    call map(s:aroundCache[a:dir], 'fuf#makePathItem(fnamemodify(v:val, ":~"), "", 0)')
    if len(g:fuf_mrufile_exclude)
      call filter(s:aroundCache[a:dir], 'v:val.word !~ g:fuf_mrufile_exclude')
    endif
  endif
  return s:aroundCache[a:dir]
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
  let levelString = (g:fuf_mrufile_searchAroundLevel < 0 ? ''
        \            : '[Around:' . g:fuf_mrufile_searchAroundLevel . ']')
  return fuf#formatPrompt(g:fuf_mrufile_prompt, self.partialMatching, levelString)
endfunction

"
function s:handler.getPreviewHeight()
  return g:fuf_previewHeight
endfunction

"
function s:handler.isOpenable(enteredPattern)
  return 1
endfunction

"
function s:handler.makePatternSet(patternBase)
  return fuf#makePatternSet(a:patternBase, 's:interpretPrimaryPatternForPath',
        \                   self.partialMatching)
endfunction

"
function s:handler.makePreviewLines(word, count)
  return fuf#makePreviewLinesForFile(a:word, a:count, self.getPreviewHeight())
endfunction

"
function s:handler.getCompleteItems(patternPrimary)
  return self.items
endfunction

"
function s:handler.onOpen(word, mode)
  if a:mode ==# s:OPEN_TYPE_EXPAND
    let nextLevel = (self.searchAroundLevel < 0 ? 0 : self.searchAroundLevel + 1)
    call fuf#setOneTimeVariables(['g:fuf_mrufile_searchAroundLevel', nextLevel])
    let self.reservedMode = self.getModeName()
    return
  else
    call fuf#openFile(a:word, a:mode, g:fuf_reuseWindow)
  endif
endfunction

"
function s:handler.onModeEnterPre()
endfunction

"
function s:handler.onModeEnterPost()
  let self.searchAroundLevel = g:fuf_mrufile_searchAroundLevel
  call fuf#defineKeyMappingInHandler(g:fuf_mrufile_keyExpand,
        \                            'onCr(' . s:OPEN_TYPE_EXPAND . ')')
  " NOTE: Comparing filenames is faster than bufnr('^' . fname . '$')
  let bufNamePrev = fnamemodify(bufname(self.bufNrPrev), ':p:~')
  if self.searchAroundLevel < 0
    let self.items = fuf#loadDataFile(s:MODE_NAME, 'items')
    call map(self.items, 's:formatItemUsingCache(v:val)')
  else
    let self.items = fuf#loadDataFile(s:MODE_NAME, 'itemdirs')
    call map(self.items, 's:expandSearchDir(v:val.word, g:fuf_mrufile_searchAroundLevel)')
    let self.items = l9#concat(self.items)
    let self.items = l9#unique(self.items)
    call map(self.items, 's:listAroundFilesUsingCache(v:val)')
    let self.items = l9#concat(self.items)
  endif
  call filter(self.items, '!empty(v:val) && v:val.word !=# bufNamePrev')
  call fuf#mapToSetSerialIndex(self.items, 1)
  call fuf#mapToSetAbbrWithSnippedWordAsPath(self.items)
endfunction

"
function s:handler.onModeLeavePost(opened)
endfunction

" }}}1
"=============================================================================
" vim: set fdm=marker:
