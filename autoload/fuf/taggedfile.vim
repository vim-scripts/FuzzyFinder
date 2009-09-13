"=============================================================================
" Copyright (c) 2007-2009 Takeshi NISHIDA
"
"=============================================================================
" LOAD GUARD {{{1

if exists('g:loaded_autoload_fuf_taggedfile') || v:version < 702
  finish
endif
let g:loaded_autoload_fuf_taggedfile = 1

" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

"
function fuf#taggedfile#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function fuf#taggedfile#getSwitchOrder()
  return g:fuf_taggedfile_switchOrder
endfunction

"
function fuf#taggedfile#renewCache()
  let s:cache = {}
endfunction

"
function fuf#taggedfile#requiresOnCommandPre()
  return 0
endfunction

"
function fuf#taggedfile#onInit()
  call fuf#defineLaunchCommand('FufTaggedFile', s:MODE_NAME, '""')
endfunction

" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

let s:MODE_NAME = expand('<sfile>:t:r')

"
function s:getTaggedFileList(tagfile)
  execute 'cd ' . fnamemodify(a:tagfile, ':h')
  let result = map(readfile(a:tagfile), 'matchstr(v:val, ''^[^!\t][^\t]*\t\zs[^\t]\+'')')
  call map(readfile(a:tagfile), 'fnamemodify(v:val, ":p")')
  cd -
  call map(readfile(a:tagfile), 'fnamemodify(v:val, ":~:.")')
  return filter(result, 'v:val =~ ''[^/\\ ]$''')
endfunction

"
function s:enumTaggedFiles(tagFiles)
  if !len(a:tagFiles)
    return []
  endif
  let key = join([getcwd()] + a:tagFiles, "\n")
  " cache not created or tags file updated? 
  if !exists('s:cache[key]') || max(map(copy(a:tagFiles), 'getftime(v:val) >= s:cache[key].time'))
    let items = fuf#unique(fuf#concat(map(copy(a:tagFiles), 's:getTaggedFileList(v:val)')))
    call map(items, 'fuf#makePathItem(v:val, 0)')
    call fuf#mapToSetSerialIndex(items, 1)
    call fuf#mapToSetAbbrWithSnippedWordAsPath(items)
    let s:cache[key] = { 'time'  : localtime(), 'items' : items }
  endif
  return s:cache[key].items
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
  return g:fuf_taggedfile_prompt
endfunction

"
function s:handler.targetsPath()
  return 1
endfunction

"
function s:handler.onComplete(patternSet)
  return fuf#filterMatchesAndMapToSetRanks(
        \ self.cache, a:patternSet,
        \ self.getFilteredStats(a:patternSet.raw), self.targetsPath())
endfunction

"
function s:handler.onOpen(expr, mode)
  call fuf#openFile(a:expr, a:mode, g:fuf_reuseWindow)
endfunction

"
function s:handler.onModeEnterPre()
  let self.tagFiles = fuf#getCurrentTagFiles()
endfunction

"
function s:handler.onModeEnterPost()
  " NOTE: Don't do this in onModeEnterPre()
  "       because it should return in a short time 
  let self.cache =
        \ filter(copy(s:enumTaggedFiles(self.tagFiles)),
        \        'bufnr("^" . v:val.word . "$") != self.bufNrPrev')
endfunction

"
function s:handler.onModeLeavePost(opened)
endfunction

" }}}1
"=============================================================================
" vim: set fdm=marker:
