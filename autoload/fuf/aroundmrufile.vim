"=============================================================================
" Copyright (c) 2010 Takeshi NISHIDA
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
function fuf#aroundmrufile#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function fuf#aroundmrufile#getSwitchOrder()
  return g:fuf_aroundmrufile_switchOrder
endfunction

"
function fuf#aroundmrufile#renewCache()
  let s:cache = {}
endfunction

"
function fuf#aroundmrufile#requiresOnCommandPre()
  return 0
endfunction

"
function fuf#aroundmrufile#onInit()
  call fuf#defineLaunchCommand('FufAroundMruFile', s:MODE_NAME, '""')
  augroup fuf#aroundmrufile
    autocmd!
    autocmd BufEnter     * call s:updateInfo()
    autocmd BufWritePost * call s:updateInfo()
  augroup END
endfunction

" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

let s:MODE_NAME = expand('<sfile>:t:r')

"
function s:updateInfo()
  if !empty(&buftype) || !filereadable(expand('%'))
    return
  endif
  let items = fuf#loadDataFile(s:MODE_NAME, 'items')
  let items = fuf#updateMruList(
        \ items, { 'word' : expand('%:p:h') },
        \ g:fuf_aroundmrufile_maxDir, g:fuf_aroundmrufile_exclude)
  call fuf#saveDataFile(s:MODE_NAME, 'items', items)
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
function s:listFilesUsingCache(dir)
  if !exists('s:cache[a:dir]')
    let s:cache[a:dir] = [a:dir] +
          \              split(glob(a:dir . l9#getPathSeparator() . "*" ), "\n") +
          \              split(glob(a:dir . l9#getPathSeparator() . ".*"), "\n")
    call filter(s:cache[a:dir], 'filereadable(v:val)')
    call map(s:cache[a:dir], 'fuf#makePathItem(fnamemodify(v:val, ":~"), "", 0)')
    if len(g:fuf_aroundmrufile_exclude)
      call filter(s:cache[a:dir], 'v:val.word !~ g:fuf_aroundmrufile_exclude')
    endif
  endif
  return s:cache[a:dir]
endfunction

" }}}1
"=============================================================================
" s:handler {{{1

let s:handler = {}
let s:OPEN_TYPE_EXPAND = -1

"
function s:handler.getModeName()
  return s:MODE_NAME
endfunction

"
function s:handler.getPrompt()
  let levelString = '[' . g:fuf_aroundmrufile_searchLevel . ']'
  return fuf#formatPrompt(g:fuf_aroundmrufile_prompt, self.partialMatching, levelString)
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
    call fuf#setOneTimeVariables(['g:fuf_aroundmrufile_searchLevel',
          \                       self.searchLevel + 1])
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
  let self.searchLevel = g:fuf_aroundmrufile_searchLevel
  call fuf#defineKeyMappingInHandler(g:fuf_aroundmrufile_keyExpand,
        \                            'onCr(' . s:OPEN_TYPE_EXPAND . ')')
  " NOTE: Comparing filenames is faster than bufnr('^' . fname . '$')
  let bufNamePrev = fnamemodify(bufname(self.bufNrPrev), ':p:~')
  let self.items = fuf#loadDataFile(s:MODE_NAME, 'items')
  call map(self.items, 's:expandSearchDir(v:val.word, g:fuf_aroundmrufile_searchLevel)')
  let self.items = l9#concat(self.items)
  let self.items = l9#unique(self.items)
  call map(self.items, 's:listFilesUsingCache(v:val)')
  let self.items = l9#concat(self.items)
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
