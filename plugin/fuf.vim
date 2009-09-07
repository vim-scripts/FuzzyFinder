"=============================================================================
" Copyright (c) 2007-2009 Takeshi NISHIDA
"
" GetLatestVimScripts: 1984 1 :AutoInstall: FuzzyFinder
"=============================================================================
" LOAD GUARD {{{1

if exists('g:loaded_fuf') || v:version < 702
  finish
endif
let g:loaded_fuf = 1

" }}}1
"=============================================================================
" LOCAL FUNCTIONS {{{1

"
function s:initialize()
  "---------------------------------------------------------------------------
  call s:defineOption('g:fuf_modes'  , [
        \   'buffer', 'file', 'dir', 'mrufile', 'mrucmd',
        \   'bookmark', 'tag', 'taggedfile', 'givenfile',
        \   'givendir', 'givencmd', 'callbackfile', 'callbackitem',
        \ ])
  call s:defineOption('g:fuf_modesDisable'  , [ 'mrufile', 'mrucmd', ])
  call s:defineOption('g:fuf_keyOpen'         , '<CR>')
  call s:defineOption('g:fuf_keyOpenSplit'    , '<C-j>')
  call s:defineOption('g:fuf_keyOpenVsplit'   , '<C-k>')
  call s:defineOption('g:fuf_keyOpenTabpage'  , '<C-l>')
  call s:defineOption('g:fuf_keyPrevPattern'  , '<C-t>')
  call s:defineOption('g:fuf_keyNextPattern'  , '<C-^>')
  call s:defineOption('g:fuf_infoFile'        , '~/.vim-fuf')
  call s:defineOption('g:fuf_abbrevMap'       , {})
  call s:defineOption('g:fuf_patternSeparator', ';')
  call s:defineOption('g:fuf_ignoreCase'      , 1)
  call s:defineOption('g:fuf_smartBs'         , 1)
  call s:defineOption('g:fuf_reuseWindow'     , 1)
  call s:defineOption('g:fuf_timeFormat'      , '(%Y-%m-%d %H:%M:%S)')
  call s:defineOption('g:fuf_learningLimit'   , 100)
  call s:defineOption('g:fuf_enumeratingLimit', 50)
  call s:defineOption('g:fuf_maxMenuWidth'    , 78)
  call s:defineOption('g:fuf_useMigemo'       , 0)
  "---------------------------------------------------------------------------
  call s:defineOption('g:fuf_buffer_prompt'         , '>Buffer>')
  call s:defineOption('g:fuf_buffer_promptHighlight', 'Question')
  call s:defineOption('g:fuf_buffer_mruOrder'       , 1)
  "---------------------------------------------------------------------------
  call s:defineOption('g:fuf_file_prompt'         , '>File>')
  call s:defineOption('g:fuf_file_promptHighlight', 'Question')
  call s:defineOption('g:fuf_file_exclude'        , '\v\~$|\.o$|\.exe$|\.bak$|\.swp$')
  "---------------------------------------------------------------------------
  call s:defineOption('g:fuf_dir_prompt'         , '>Dir>')
  call s:defineOption('g:fuf_dir_promptHighlight', 'Question')
  call s:defineOption('g:fuf_dir_exclude'        , '')
  "---------------------------------------------------------------------------
  call s:defineOption('g:fuf_mrufile_prompt'         , '>MruFile>')
  call s:defineOption('g:fuf_mrufile_promptHighlight', 'Question')
  call s:defineOption('g:fuf_mrufile_exclude'        , '\v\~$|\.bak$|\.swp$')
  call s:defineOption('g:fuf_mrufile_maxItem'        , 200)
  "---------------------------------------------------------------------------
  call s:defineOption('g:fuf_mrucmd_prompt'         , '>MruCmd>')
  call s:defineOption('g:fuf_mrucmd_promptHighlight', 'Question')
  call s:defineOption('g:fuf_mrucmd_exclude'        , '^$')
  call s:defineOption('g:fuf_mrucmd_maxItem'        , 200)
  "---------------------------------------------------------------------------
  call s:defineOption('g:fuf_bookmark_prompt'         , '>Bookmark>')
  call s:defineOption('g:fuf_bookmark_promptHighlight', 'Question')
  call s:defineOption('g:fuf_bookmark_searchRange' , 400)
  "---------------------------------------------------------------------------
  call s:defineOption('g:fuf_tag_prompt'         , '>Tag>')
  call s:defineOption('g:fuf_tag_promptHighlight', 'Question')
  "---------------------------------------------------------------------------
  call s:defineOption('g:fuf_taggedfile_prompt'         , '>TaggedFile>')
  call s:defineOption('g:fuf_taggedfile_promptHighlight', 'Question')
  "---------------------------------------------------------------------------
  call s:defineOption('g:fuf_givenfile_prompt'         , '>GivenFile>')
  call s:defineOption('g:fuf_givenfile_promptHighlight', 'Question')
  "---------------------------------------------------------------------------
  call s:defineOption('g:fuf_givendir_prompt'         , '>GivenDir>')
  call s:defineOption('g:fuf_givendir_promptHighlight', 'Question')
  "---------------------------------------------------------------------------
  call s:defineOption('g:fuf_givencmd_prompt'         , '>GivenCmd>')
  call s:defineOption('g:fuf_givencmd_promptHighlight', 'Question')
  "---------------------------------------------------------------------------
  call s:defineOption('g:fuf_callbackfile_prompt'         , '>CallbackFile>')
  call s:defineOption('g:fuf_callbackfile_promptHighlight', 'Question')
  call s:defineOption('g:fuf_callbackfile_exclude'        , '')
  "---------------------------------------------------------------------------
  call s:defineOption('g:fuf_callbackitem_prompt'         , '>CallbackItem>')
  call s:defineOption('g:fuf_callbackitem_promptHighlight', 'Question')
  "---------------------------------------------------------------------------
  call filter(g:fuf_modes, 'count(g:fuf_modesDisable, v:val) == 0')
  for m in g:fuf_modes
    call fuf#{m}#renewCache()
    call fuf#{m}#onInit()
  endfor
  "---------------------------------------------------------------------------
  command! -bang -narg=0 FufEditInfo   call fuf#editInfoFile()
  command! -bang -narg=0 FufRenewCache call s:renewCachesOfAllModes()
  "---------------------------------------------------------------------------
  for m in g:fuf_modes
    if fuf#{m}#requiresOnCommandPre()
      " cnoremap has a problem, which doesn't expand cabbrev.
      cmap <silent> <expr> <CR> <SID>onCommandPre()
      break
    endif
  endfor
  "---------------------------------------------------------------------------
endfunction

"
function s:initMisc()
endfunction

"
function s:defineOption(name, default)
  if !exists(a:name)
    let {a:name} = a:default
  endif
endfunction

"
function s:renewCachesOfAllModes()
  for m in g:fuf_modes 
    call fuf#{m}#renewCache()
  endfor
endfunction

"
function s:onBufEnter()
  for m in g:fuf_modes 
    call fuf#{m}#onBufEnter()
  endfor
endfunction

"
function s:onBufWritePost()
  for m in g:fuf_modes
    call fuf#{m}#onBufWritePost()
  endfor
endfunction

"
function s:onCommandPre()
  for m in filter(copy(g:fuf_modes), 'fuf#{v:val}#requiresOnCommandPre()')
      call fuf#{m}#onCommandPre(getcmdtype() . getcmdline())
  endfor
  " lets last entry become the newest in the history
  call histadd(getcmdtype(), getcmdline())
  " this is not mapped again (:help recursive_mapping)
  return "\<CR>"
endfunction

" }}}1
"=============================================================================
" INITIALIZATION {{{1

call s:initialize()

" }}}1
"=============================================================================
" vim: set fdm=marker:
