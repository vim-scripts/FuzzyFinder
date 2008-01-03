""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" fuzzyfinder.vim : The buffer/file/MRU/favorite/etc. explorer
"                   with the fuzzy pattern
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Last Change:  04-Jan-2008.
" Author:       Takeshi Nishida <ns9tks(at)gmail(dot)com>
" Version:      2.0, for Vim 7.1
" Licence:      MIT Licence
" URL:          http://www.vim.org/scripts/script.php?script_id=1984
"
"-----------------------------------------------------------------------------
" Description:
"   Fuzzyfinder provides convenient ways to quickly reach the
"   buffer/file/command you want. Fuzzyfinder finds matching
"   files/buffers/commands with a fuzzy pattern to which it converted the
"   entered pattern.
"
"   E.g.: the entered pattern / the fuzzy pattern
"     abc      -> *a*b*c*
"     a?c      -> *a?c*         (? matches one character.)
"     dir/file -> dir/*f*i*l*e*
"     d*r/file -> d*r/*f*i*l*e*
"     ../**/s  -> ../**/*s*     (** allows searching a directory tree.)
"
"   You will be happy when:
"     "./OhLongLongLongLongLongFile.txt"
"     "./AhLongLongLongLongLongName.txt"
"     "./AhLongLongLongLongLongFile.txt" <- you want :O
"     Type "AF" and "AhLongLongLongLongLongFile.txt" will be select. :D
"
"   Fuzzyfinder has some modes:
"     - Buffer mode
"     - File mode
"     - MRU-file mode (most recently used files)
"     - MRU-command mode (most recently used commands)
"     - Favorite-file mode
"     - Directory mode (yet another :cd command)
"     - Tag mode (yet another :tag command)
"     - Tagged-file mode (files which are included in current tags)
"
"   Fuzzyfinder supports the multibyte.
"
"-----------------------------------------------------------------------------
" Installation:
"   Drop this file in your plugin directory. If you have installed
"   autocomplpop.vim (vimscript #1879), please update to the latest version
"   to prevent interference.
"
"-----------------------------------------------------------------------------
" Usage:
"   Starting The Explorer:
"     You can start the explorer by the following commands:
"
"       :FuzzyFinderBuffer      - launchs the buffer explorer.
"       :FuzzyFinderFile        - launchs the file explorer.
"       :FuzzyFinderMruFile     - launchs the MRU-file explorer.
"       :FuzzyFinderMruCmd      - launchs the MRU-command explorer.
"       :FuzzyFinderFavFile     - launchs the favorite-file explorer.
"       :FuzzyFinderDir         - launchs the directory explorer.
"       :FuzzyFinderTag         - launchs the tag explorer.
"       :FuzzyFinderTaggedFile  - launchs the tagged-file explorer.
"
"     It is recommended to map these.
"
"   In The Explorer:
"     The entered pattern is converted to the fuzzy pattern and buffers/files
"     which match the pattern is shown in a completion menu.
"
"     A completion menu is shown when you type at the end of the line and the
"     length of entered pattern is more than setting value. By default, it
"     is shown at the beginning.
"
"     If too many items (400, by default) were matched, the completion is
"     aborted to reduce nonresponse.
"
"     If entered pattern matched the item perfectly, the item is shown
"     first. Same applies to the item number in the buffer/MRU/favorite mode.
"     The item whose file name has longer prefix matching is placed upper. The
"     item which matched more sequentially is placed upper. It lets the first
"     item into selected in completion menu.
"
"     Pressing <CR> opens selected item in previous window. If selected item
"     was a directory in the file mode, it just inserts text. Use <C-j> to
"     open in new window which is made from split previous window, or <C-k> To
"     open in new window which is made from split previous window vertically.
"     In MRU-commands mode, press <CR> and it executes selected command, or
"     press <C-j>/<C-k> and it just puts text into the command-line. These key
"     mappings are customizable.
"
"     To cancel and return to previous window, leave the insert mode.
"
"     To Switch the mode without leaving a insert mode, use <C-l> or <C-o>.
"     This key mapping is customizable.
"
"     If you want to temporarily change whether or not to ignore case, use
"     <C-t>. This key mapping is customizable.
"
"   About Tagged File Mode:
"     The files which are included in the current tags are the ones which are
"     related to the current working environment. So this mode is a pseudo
"     project mode.
"
"   About Abbreviations And Multiple Search:
"     You can use abbreviations and multiple search in each mode. For
"     example, set as below:
"
"       :let g:FuzzyFinderOptions = {
"             \   'file' : {
"             \     'abbrev_map' : {
"             \       "^WORK" : [
"             \         "~/project/**/src/",
"             \         ".vim/plugin/",
"             \       ]
"             \     }
"             \   }
"             \ }
"
"     And type "WORKtxt" in the file-mode explorer, then it searches by
"     following patterns:
"
"       "~/project/**/src/*t*x*t*"
"       ".vim/plugin/*t*x*t*"
"
"   Adding Favorite Files:
"     You can add a favorite file by the following commands:
"
"       :FuzzyFinderAddFavFile {filename}
"
"     If you do not specify the filename, current file name is used.
"
"   About Information File:
"     Fuzzyfinder writes information of the MRU, favorite, etc to the file
"     by default (~/.vimfuzzyfinder).
"
"   About Cache:
"     Once a cache was created, It is not updated automatically to improve
"     response by default. To update it, use :FuzzyFinderRemoveCache command.
"
"   About Migemo:
"     Migemo is a search method for Japanese language.
"
"-----------------------------------------------------------------------------
" Options:
"   g:FuzzyFinderOptions:
"     You can set options via g:FuzzyFinderOptions which is a dictionary. To
"     copy s:opt_default as g:FuzzyFinderOptions into your .vimrc and edit is
"     an easy way to set options.
".............................................................................
"     ['key_open']:
"       This is mapped to select completion item or finish input and open a
"       buffer/file in previous window.
".............................................................................
"     ['key_open_split']:
"       This is mapped to select completion item or finish input and open a
"       buffer/file in split new window
".............................................................................
"     ['key_open_vsplit']:
"       This is mapped to select completion item or finish input and open a
"       buffer/file in vertical-split new window.
".............................................................................
"     ['key_next_mode']:
"       This is mapped to switch to the next mode.
".............................................................................
"     ['key_prev_mode']:
"       This is mapped to switch to the previous mode.
".............................................................................
"     ['key_ignore_case']:
"       This is mapped to temporarily switch whether or not to ignore case.
".............................................................................
"     ['info_file']:
"       This is the file name to write information of the MRU, etc. If "" was
"       set, it does not write to the file.
".............................................................................
"     ['ignore_case']:
"       It ignores case in search patterns if non-zero is set.
".............................................................................
"     ['migemo_support']:
"       It uses Migemo if non-zero is set.
".............................................................................
"     ['buffer']:
"       This is a dictionary of option set which applies to the buffer mode.
"
"       ['mode_available']:
"         It disables all functions of this mode if zero was set.
"
"       ['initial_text']:
"         This is a text which is inserted at the beginning of the mode.
"
"       ['abbrev_map']:
"         This is a dictionary. Each value must be a list. All matchs of a key
"         in entered text is expanded with the value.
"
"       ['min_length']:
"         It does not start a completion if a length of entered text is less
"         than this.
"
"       ['excluded_indicator']:
"         Items whose indicators match this are excluded.
".............................................................................
"     ['file']:
"       This is a dictionary of option set which applies to the file mode.
"
"       ['mode_available']:
"         It disables all functions of this mode if zero was set.
"
"       ['initial_text']:
"         This is a text which is inserted at the beginning of the mode.
"
"       ['abbrev_map']:
"         This is a dictionary. Each value must be a list. All matchs of a key
"         in entered text is expanded with a value.
"
"       ['min_length']:
"         It does not start a completion if a length of entered text is less
"         than this.
"
"       ['excluded_path']:
"         Items whose paths match this are excluded.
"
"       ['max_match']:
"         If a number of matched items was over this, the completion process
"         is aborted. If zero was set, it does not limit.
"
"       ['lasting_cache']:
"         It does not remove caches of completion lists at the end of explorer
"         if non-zero was set.
".............................................................................
"     ['mru_file']:
"       This is a dictionary of option set which applies to the MRU-file mode.
"       ['mode_available']:
"         It disables all functions of this mode if zero was set.
"
"       ['initial_text']:
"         This is a text which is inserted at the beginning of the mode.
"
"       ['abbrev_map']:
"         This is a dictionary. Each value must be a list. All matchs of a key
"         in entered text is expanded with a value. 
"
"       ['min_length']:
"         It does not start a completion if a length of entered text is less
"         than this.
"
"       ['excluded_path']:
"         Items whose paths match this are excluded.
"
"       ['no_special_buffer']:
"         It ignores special buffers if non-zero was set.
"
"       ['time_format']:
"         This is a string to format registered time. See :help strftime() for
"         details.
"
"       ['max_item']:
"         This is an upper limit of MRU items to be stored. If zero was set,
"         it does not limit.
".............................................................................
"     ['mru_cmd']:
"       This is a dictionary of option set which applies to the MRU-command
"       mode.
"       ['mode_available']:
"         It disables all functions of this mode if zero was set.
"
"       ['initial_text']:
"         This is a text which is inserted at the beginning of the mode.
"
"       ['abbrev_map']:
"         This is a dictionary. Each value must be a list. All matchs of a key
"         in entered text is expanded with a value. 
"
"       ['min_length']:
"         It does not start a completion if a length of entered text is less
"         than this.
"
"       ['excluded_command']:
"         Items whose commands match this are excluded.
"
"       ['time_format']:
"         This is a string to format registered time. See :help strftime() for
"         details.
"
"       ['max_item']:
"         This is an upper limit of MRU items to be stored. If zero was set,
"         it does not limit.
".............................................................................
"     ['fav_file']:
"       This is a dictionary of option set which applies to the favorite-file
"       mode.
"       ['mode_available']:
"         It disables all functions of this mode if zero was set.
"
"       ['initial_text']:
"         This is a text which is inserted at the beginning of the mode.
"
"       ['abbrev_map']:
"         This is a dictionary. Each value must be a list. All matchs of a key
"         in entered text is expanded with a value. 
"
"       ['min_length']:
"         It does not start a completion if a length of entered text is less
"         than this.
"
"       ['time_format']:
"         This is a string to format registered time. See :help strftime() for
"         details.
".............................................................................
"     ['dir']:
"       This is a dictionary of option set which applies to the directory mode.
"       ['mode_available']:
"         It disables all functions of this mode if zero was set.
"
"       ['initial_text']:
"         This is a text which is inserted at the beginning of the mode.
"
"       ['abbrev_map']:
"         This is a dictionary. Each value must be a list. All matchs of a key
"         in entered text is expanded with a value. 
"
"       ['min_length']:
"         It does not start a completion if a length of entered text is less
"         than this.
"
"       ['excluded_path']:
"         Items whose paths match this are excluded.
".............................................................................
"     ['tag']:
"       This is a dictionary of option set which applies to the tag mode.
"
"       ['mode_available']:
"         It disables all functions of this mode if zero was set.
"
"       ['initial_text']:
"         This is a text which is inserted at the beginning of the mode.
"
"       ['abbrev_map']:
"         This is a dictionary. Each value must be a list. All matchs of a key
"         in entered text is expanded with a value. 
"
"       ['min_length']:
"         It does not start a completion if a length of entered text is less
"         than this.
"
"       ['excluded_path']:
"         Items whose paths match this are excluded.
"
"       ['max_match']:
"         If a number of matched items was over this, the completion process
"         is aborted. If zero was set, it does not limit.
"
"       ['lasting_cache']:
"         It does not remove caches of completion lists at the end of explorer
"         if non-zero was set.
".............................................................................
"     ['tagged_file']:
"       This is a dictionary of option set which applies to the tagged-file mode.
"
"       ['mode_available']:
"         It disables all functions of this mode if zero was set.
"
"       ['initial_text']:
"         This is a text which is inserted at the beginning of the mode.
"
"       ['abbrev_map']:
"         This is a dictionary. Each value must be a list. All matchs of a key
"         in entered text is expanded with a value. 
"
"       ['min_length']:
"         It does not start a completion if a length of entered text is less
"         than this.
"
"       ['max_match']:
"         If a number of matched items was over this, the completion process
"         is aborted. If zero was set, it does not limit.
"
"       ['lasting_cache']:
"         It does not remove caches of completion lists at the end of explorer
"         if non-zero was set.
".............................................................................
"
"-----------------------------------------------------------------------------
" Settings Example:
"   let  g:FuzzyFinderOptions = {
"         \   'ignore_case' : 1,
"         \
"         \   'file' : {
"         \     'abbrev_map' : {
"         \       '\C^VP' : [
"         \         '$VIMRUNTIME/plugin/',
"         \         '~/.vim/plugin/',
"         \         '$VIM/.vim/plugin/',
"         \         '$VIM/vimfiles/plugin/',
"         \       ],
"         \       '\C^VC' : [
"         \         '$VIMRUNTIME/colors/',
"         \         '~/.vim/colors/',
"         \         '$VIM/.vim/colors/',
"         \         '$VIM/vimfiles/colors/',
"         \       ],
"         \     },
"         \   },
"         \
"         \   'mru_file' : {
"         \       'maxItems' : 99,
"         \   },
"         \
"         \   'mru_cmd' : {
"         \       'maxItems' : 99,
"         \   },
"         \
"         \ }
"     :nnoremap <C-n>      :FuzzyFinderBuffer<CR>
"     :nnoremap <C-p>      :FuzzyFinderFile<CR>
"     :nnoremap <C-f><C-n> :FuzzyFinderMruFile<CR>
"     :nnoremap <C-f><C-p> :FuzzyFinderMruCmd<CR>
"     :nnoremap <C-f><C-f> :FuzzyFinderFavFile<CR>
"     :nnoremap <C-f><C-d> :FuzzyFinderDir<CR>
"     :nnoremap <C-f><C-t> :FuzzyFinderTag<CR>
"     :nnoremap <C-f><C-g> :FuzzyFinderTaggedFile<CR>
"
"-----------------------------------------------------------------------------
" Thanks:
"   Vincent Wang
"   Ingo Karkat
"   Nikolay Golubev
"   Brian Doyle
"
"-----------------------------------------------------------------------------
" ChangeLog:
"   2.0:
"     - Added the tag mode.
"     - Added the tagged-file mode.
"     - Added :FuzzyFinderRemoveCache command.
"     - Restructured the option system. many options are changed names or
"       default values of some options.
"     - Changed to hold and reuse caches of completion lists by default.
"     - Changed to set filetype 'fuzzyfinder'.
"     - Disabled the MRU-command mode by default because there are problems.
"     - Removed FuzzyFinderAddMode command.
"
"   1.5:
"     - Added the directory mode.
"     - Fixed the bug that it caused an error when switch a mode in the insert
"       mode.
"     - Changed g:FuzzyFinder_KeySwitchMode type to a list.
"
"   1.4:
"     - Changed the specification of the information file.
"     - Added the MRU-commands mode.
"     - Renamed :FuzzyFinderAddFavorite command to :FuzzyFinderAddFavFile.
"     - Renamed g:FuzzyFinder_MruModeVars option to
"       g:FuzzyFinder_MruFileModeVars.
"     - Renamed g:FuzzyFinder_FavoriteModeVars option to
"       g:FuzzyFinder_FavFileModeVars.
"     - Changed to show registered time of each item in MRU/favorite mode.
"     - Added 'timeFormat' option for MRU/favorite modes.
"
"   1.3:
"     - Fixed a handling of multi-byte characters.
"
"   1.2:
"     - Added support for Migemo. (Migemo is Japanese search method.)
"
"   1.1:
"     - Added the favorite mode.
"     - Added new features, which are abbreviations and multiple search.
"     - Added 'abbrevMap' option for each mode.
"     - Added g:FuzzyFinder_MruModeVars['ignoreSpecialBuffers'] option.
"     - Fixed the bug that it did not work correctly when a user have mapped
"       <C-p> or <Down>.
"
"   1.0:
"     - Added the MRU mode.
"     - Added commands to add and use original mode.
"     - Improved the sorting algorithm for completion items.
"     - Added 'initialInput' option to automatically insert a text at the
"       beginning of a mode.
"     - Changed that 'excludedPath' option works for the entire path.
"     - Renamed some options. 
"     - Changed default values of some options. 
"     - Packed the mode-specific options to dictionaries.
"     - Removed some options.
"
"   0.6:
"     - Fixed some bugs.

"   0.5:
"     - Improved response by aborting processing too many items.
"     - Changed to be able to open a buffer/file not only in previous window
"       but also in new window.
"     - Fixed a bug that recursive searching with '**' does not work.
"     - Added g:FuzzyFinder_CompletionItemLimit option.
"     - Added g:FuzzyFinder_KeyOpen option.
"
"   0.4:
"     - Improved response of the input.
"     - Improved the sorting algorithm for completion items. It is based on
"       the matching level. 1st is perfect matching, 2nd is prefix matching,
"       and 3rd is fuzzy matching.
"     - Added g:FuzzyFinder_ExcludePattern option.
"     - Removed g:FuzzyFinder_WildIgnore option.
"     - Removed g:FuzzyFinder_EchoPattern option.
"     - Removed g:FuzzyFinder_PathSeparator option.
"     - Changed the default value of g:FuzzyFinder_MinLengthFile from 1 to 0.
"
"   0.3:
"     - Added g:FuzzyFinder_IgnoreCase option.
"     - Added g:FuzzyFinder_KeyToggleIgnoreCase option.
"     - Added g:FuzzyFinder_EchoPattern option.
"     - Changed the open command in a buffer mode from ":edit" to ":buffer" to
"       avoid being reset cursor position.
"     - Changed the default value of g:FuzzyFinder_KeyToggleMode from
"       <C-Space> to <F12> because <C-Space> does not work on some CUI
"       environments.
"     - Changed to avoid being loaded by Vim before 7.0.
"     - Fixed a bug with making a fuzzy pattern which has '\'.
"
"   0.2:
"     - A bug it does not work on Linux is fixed.
"
"   0.1:
"     - First release.
"
"
"-----------------------------------------------------------------------------

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INCLUDE GUARD:
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists('loaded_fuzzyfinder') || v:version < 700
  finish
endif
let loaded_fuzzyfinder = 1


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INITIALIZATION FUNCTION:
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>Initialize()
  "-------------------------------------------------------------------------
  " CONSTANTS
  let s:info_version = 104
  let s:path_separator = has('win32') ? '\' : '/'
  let s:prompt = '>'
  let s:matching_rate_base = 10000000
  let s:sid_prefix = matchstr(expand('<sfile>'), '<SNR>\d\+_')
  let s:msg_rm_info = "==================================================\n" .
        \             "  Your fuzzyfinder information file is no longer \n"  .
        \             "  supported. Please remove\n"                         .
        \             "  \"%s\".\n"                                          .
        \             "=================================================="

  "-------------------------------------------------------------------------
  " OPTIONS
  if !exists('g:FuzzyFinderOptions')
    let g:FuzzyFinderOptions = {}
  endif
  let opt_default = {
        \   'key_open'        : '<CR>',
        \   'key_open_split'  : '<C-j>',
        \   'key_open_vsplit' : '<C-k>',
        \   'key_next_mode'   : '<C-l>',
        \   'key_prev_mode'   : '<C-o>',
        \   'key_ignore_case' : '<C-t>',
        \
        \   'info_file' : '~/.vimfuzzyfinder',
        \
        \   'ignore_case' : &ignorecase,
        \
        \   'migemo_support' : 0,
        \
        \   'buffer' : {
        \     'complete'           : function('<SID>CompleteBuffer'),
        \     'open'               : function('<SID>OpenBuffer'),
        \     'buffer_name'        : '[FuzzyFinder - Buffer]',
        \     'mode_available'     : 1,
        \     'initial_text'       : '',
        \     'abbrev_map'         : {},
        \     'min_length'         : 0,
        \     'excluded_indicator' : '[u\-]',
        \   } ,
        \
        \   'file' : {
        \     'complete'           : function('<SID>CompleteFile'),
        \     'open'               : function('<SID>OpenFile'),
        \     'buffer_name'        : '[FuzzyFinder - File]',
        \     'mode_available'     : 1,
        \     'initial_text'       : '',
        \     'abbrev_map'         : {},
        \     'min_length'         : 0,
        \     'excluded_path'      : '\v\~$|\.o$|\.exe$|\.bak$|\.swp$|((^|[/\\])\.[/\\]$)',
        \     'max_match'          : 400,
        \     'aborted_abbr'       : 'ABORT: Too many matches (>g:FuzzyFinderOptions.file.max_match)',
        \     'lasting_cache'      : 1,
        \   } ,
        \
        \   'mru_file' : {
        \     'complete'           : function('<SID>CompleteMruFile'),
        \     'open'               : function('<SID>OpenFile'),
        \     'buffer_name'        : '[FuzzyFinder - MRU File]',
        \     'mode_available'     : 1,
        \     'initial_text'       : '',
        \     'abbrev_map'         : {},
        \     'min_length'         : 0,
        \     'excluded_path'      : '\v\~$|\.bak$|\.swp$',
        \     'no_special_buffer'  : 1,
        \     'time_format'        : '(%x %H:%M:%S)',
        \     'max_item'           : 50,
        \   } ,
        \
        \   'mru_cmd' : {
        \     'complete'           : function('<SID>CompleteMruCmd'),
        \     'open'               : function('<SID>OpenMruCmd'),
        \     'buffer_name'        : '[FuzzyFinder - MRU Command]',
        \     'mode_available'     : 0,
        \     'initial_text'       : '',
        \     'abbrev_map'         : {},
        \     'min_length'         : 0,
        \     'excluded_command'   : '^.\{0,4}$',
        \     'time_format'        : '(%x %H:%M:%S)',
        \     'max_item'           : 50,
        \   } ,
        \
        \   'fav_file' : {
        \     'complete'           : function('<SID>CompleteFavFile'),
        \     'open'               : function('<SID>OpenFile'),
        \     'buffer_name'        : '[FuzzyFinder - Favorite File]',
        \     'mode_available'     : 1,
        \     'initial_text'       : '',
        \     'abbrev_map'         : {},
        \     'min_length'         : 0,
        \     'time_format'        : '(%x %H:%M:%S)',
        \   } ,
        \
        \   'dir' : {
        \     'complete'           : function('<SID>CompleteDir'),
        \     'open'               : function('<SID>OpenDir'),
        \     'buffer_name'        : '[FuzzyFinder - Directory]',
        \     'mode_available'     : 1,
        \     'initial_text'       : "\<C-r>=fnamemodify('.', ':p')\<CR>",
        \     'abbrev_map'         : {},
        \     'min_length'         : 0,
        \     'excluded_path'      : '\v(^|[/\\])\.{1,2}[/\\]$',
        \   },
        \
        \   'tag' : {
        \     'complete'           : function('<SID>CompleteTag'),
        \     'open'               : function('<SID>OpenTag'),
        \     'buffer_name'        : '[FuzzyFinder - Tag]',
        \     'mode_available'     : 1,
        \     'initial_text'       : '',
        \     'abbrev_map'         : {},
        \     'min_length'         : 0,
        \     'excluded_path'      : '\v\~$|\.bak$|\.swp$',
        \     'lasting_cache'      : 1,
        \     'max_match'          : 400,
        \     'aborted_abbr'       : 'ABORT: Too many matches (>g:FuzzyFinderOptions.tag.max_match)',
        \   },
        \
        \   'tagged_file' : {
        \     'complete'           : function('<SID>CompleteTaggedFile'),
        \     'open'               : function('<SID>OpenFile'),
        \     'buffer_name'        : '[FuzzyFinder - Tagged File]',
        \     'mode_available'     : 1,
        \     'initial_text'       : '',
        \     'abbrev_map'         : {},
        \     'min_length'         : 0,
        \     'lasting_cache'      : 1,
        \     'max_match'          : 400,
        \     'aborted_abbr'       : 'ABORT: Too many matches (>g:FuzzyFinderOptions.tagged_file.max_match)',
        \   },
        \
        \ }
  for [key, value] in items(opt_default)
    call extend(g:FuzzyFinderOptions, { key : value}, 'keep')
    if type(value) == type({})
      call extend(g:FuzzyFinderOptions[key], value, 'keep')
    endif
    unlet value
  endfor

  "-------------------------------------------------------------------------
  " COMMANDS
  command! -bar -narg=0                FuzzyFinderBuffer      call <SID>OpenFuzzyFinder('buffer')
  command! -bar -narg=0                FuzzyFinderFile        call <SID>OpenFuzzyFinder('file')
  command! -bar -narg=0                FuzzyFinderMruFile     call <SID>OpenFuzzyFinder('mru_file')
  command! -bar -narg=0                FuzzyFinderMruCmd      call <SID>OpenFuzzyFinder('mru_cmd')
  command! -bar -narg=0                FuzzyFinderFavFile     call <SID>OpenFuzzyFinder('fav_file')
  command! -bar -narg=0                FuzzyFinderDir         call <SID>OpenFuzzyFinder('dir')
  command! -bar -narg=0                FuzzyFinderTag         call <SID>OpenFuzzyFinder('tag')
  command! -bar -narg=0                FuzzyFinderTaggedFile  call <SID>OpenFuzzyFinder('tagged_file')
  command! -bar -narg=1                FuzzyFinder            call <SID>OpenFuzzyFinder(<args>)
  command! -bar -narg=? -complete=file FuzzyFinderAddFavFile  call <SID>UpdateFavFileInfo(<q-args>, 1)
  command! -bar -narg=0                FuzzyFinderRemoveCache let s:cache = {} | call garbagecollect()

  "-------------------------------------------------------------------------
  " AUTOCOMMANDS
  augroup FuzzyFinderGlobalAutoCommand
    autocmd!
    autocmd BufEnter     * call <SID>OnBufEnter()
    autocmd BufWritePost * call <SID>OnBufWritePost()
  augroup END

  "-------------------------------------------------------------------------
  " MAPPING
  if g:FuzzyFinderOptions.mru_cmd.mode_available
    cnoremap <silent> <expr> <CR> <SID>OnCmdLineCR()
  endif

  "-------------------------------------------------------------------------
  " ETC
  let s:opt = g:FuzzyFinderOptions " just alias
  let s:cache = {}
  let s:info = <SID>ReadInfoFile()

endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FUNCTIONS:
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"-----------------------------------------------------------------------------
function! <SID>OpenFuzzyFinder(mode)
  if !has_key(s:opt, a:mode) || !s:opt[a:mode].mode_available
    echo 'This mode is not available: ' . a:mode
    return
  endif
  let s:info = <SID>ReadInfoFile()
  let s:cur_mode = a:mode
  let s:last_col = -1

  if exists('s:buf_nr')
    " a buffer for fuzzyfinder was already created
    execute 'buffer ' . s:buf_nr
    delete _
  else
    1new
    let s:buf_nr = bufnr('%')

    " suspend autocomplpop.vim
    if exists(':AutoComplPopLock')
      :AutoComplPopLock
    endif

    ".....................................................................
    " global setting
    let s:_completeopt = &completeopt
    let &completeopt = 'menuone'
    let s:_ignorecase = &ignorecase
    let &ignorecase = s:opt.ignore_case

    ".....................................................................
    " local setting
    setlocal filetype=fuzzyfinder
    setlocal bufhidden=wipe
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal nobuflisted
    setlocal modifiable
    let &l:completefunc = s:sid_prefix . 'Complete'


    ".....................................................................
    " autocommands
    augroup FuzzyFinderLocalAutoCommand
      autocmd!
      autocmd CursorMovedI <buffer>        call feedkeys(<SID>OnCursorMovedI(), 'n')
      autocmd InsertLeave  <buffer> nested call feedkeys(<SID>OnInsertLeave() , 'n')
      autocmd BufLeave     <buffer>        call feedkeys(<SID>OnBufLeave()    , 'n')
    augroup END

    ".....................................................................
    " mapping
    execute "inoremap <buffer> <silent> <expr> " . s:opt.key_open        . " <SID>OnCR(0, 0)"
    execute "inoremap <buffer> <silent> <expr> " . s:opt.key_open_split  . " <SID>OnCR(1, 0)"
    execute "inoremap <buffer> <silent> <expr> " . s:opt.key_open_vsplit . " <SID>OnCR(2, 0)"
    execute "inoremap <buffer> <silent> <expr> " . "<BS>"                . " <SID>OnBS()"
    execute "inoremap <buffer> <silent> <expr> " . s:opt.key_next_mode   . " <SID>OnSwitchMode(+1)"
    execute "inoremap <buffer> <silent> <expr> " . s:opt.key_prev_mode   . " <SID>OnSwitchMode(-1)"
    execute "inoremap <buffer> <silent> <expr> " . s:opt.key_ignore_case . " <SID>OnSwitchIgnoreCase()"

  endif

  execute 'file ' . s:opt[s:cur_mode].buffer_name

  " Starts insert mode and makes CursorMovedI event now. Command prompt is
  " needed to forces a completion menu to update every typing.
  call feedkeys('i' . s:prompt . s:opt[s:cur_mode].initial_text, 'n')
endfunction

"-----------------------------------------------------------------------------
function! <SID>Complete(findstart, base)
  if a:findstart
    return 0
  endif

  let result = []

  if <SID>ExistsPrompt(a:base) && strlen(a:base) >= s:opt[s:cur_mode].min_length
    for expanded_base in <SID>ExpandAbbrevMap(a:base[strlen(s:prompt):], s:opt[s:cur_mode].abbrev_map)
      let result += s:opt[s:cur_mode].complete(expanded_base)
    endfor
  endif

  if empty(result)
    return []
  endif

  if has_key(result[0], 'order')
    call sort(result, '<SID>SortByMultipleOrder')
  endif

  call feedkeys("\<C-p>\<Down>", 'n')

  return result
endfunction

"-----------------------------------------------------------------------------
function! <SID>CompleteBuffer(base)
  let patterns = <SID>MakeFuzzyPattern(a:base)

  redir => buffers | silent buffers! | redir END

  echo 'pattern:' . patterns.wi . (s:opt.migemo_support ? ' + migemo' : '')

  let matchlist_pattern = '^\s*\(\d*\)\([^"]*\)"\([^"]*\)".*$'
  return map(filter(map(split(buffers, "\n"),
        \               'matchlist(v:val, matchlist_pattern)'),
        \           'v:val[1] != s:buf_nr && v:val[2] !~ s:opt[s:cur_mode].excluded_indicator && ' .
        \           '(v:val[1] == patterns.base || v:val[3] =~ patterns.re)'),
        \    '<SID>MakeCompletionItem(v:val[3], v:val[1], v:val[2] . v:val[3], "", a:base, 1)'
        \   )
endfunction

"-----------------------------------------------------------------------------
function! <SID>CompleteFile(base)
  let patterns = map(<SID>SplitPath(a:base), '<SID>MakeFuzzyPattern(v:val)')

  echo 'Making file list...'
  let result = <SID>GlobEx(patterns[0].base, patterns[1].re, s:opt[s:cur_mode].excluded_path)

  echo 'Evaluating...'
  if s:opt[s:cur_mode].max_match > 0 && len(result) > s:opt[s:cur_mode].max_match
    let result = [ { 'word': (len(a:base) > 0 ? a:base : ' '),
          \          'abbr': s:opt[s:cur_mode].aborted_abbr } ]
  else
    call map(result, '<SID>MakeCompletionItem(v:val, -1, v:val, "", a:base, 1)')
  endif

  echo 'pattern:' . patterns[0].base . patterns[1].wi . (s:opt.migemo_support ? ' + migemo' : '')

  return result
endfunction

"-----------------------------------------------------------------------------
function! <SID>CompleteMruFile(base)
  let patterns = <SID>MakeFuzzyPattern(a:base)

  if !has_key(s:info, 'mru_file')
    return []
  endif

  echo 'pattern:' . patterns.wi . (s:opt.migemo_support ? ' + migemo' : '')

  return map(filter(<SID>MakeNumberedList(copy(s:info.mru_file), 1),
        \           'v:val[0] == patterns.base || v:val[1].path =~ patterns.re'),
        \    '<SID>MakeCompletionItem(v:val[1].path, v:val[0], v:val[1].path,
        \                             strftime(s:opt[s:cur_mode].time_format,
        \                                      v:val[1].time),
        \                             a:base, 1)'
        \   )
endfunction

"-----------------------------------------------------------------------------
function! <SID>CompleteMruCmd(base)
  let patterns = <SID>MakeFuzzyPattern(a:base)

  if !has_key(s:info, 'mru_cmd')
    return []
  endif

  echo 'pattern:' . patterns.wi . (s:opt.migemo_support ? ' + migemo' : '')

  return map(filter(<SID>MakeNumberedList(copy(s:info.mru_cmd), 1),
        \           'v:val[0] == patterns.base || v:val[1].command =~ patterns.re'),
        \    '<SID>MakeCompletionItem(v:val[1].command, v:val[0], v:val[1].command,
        \                             strftime(s:opt[s:cur_mode].time_format,
        \                                      v:val[1].time),
        \                             a:base, 0)'
        \   )
endfunction

"-----------------------------------------------------------------------------
function! <SID>CompleteFavFile(base)
  let patterns = <SID>MakeFuzzyPattern(a:base)

  if !has_key(s:info, 'fav_file')
    return []
  endif

  echo 'pattern:' . patterns.wi . (s:opt.migemo_support ? ' + migemo' : '')

  return map(filter(<SID>MakeNumberedList(copy(s:info.fav_file), 1),
        \           'v:val[0] == patterns.base || v:val[1].path =~ patterns.re'),
        \    '<SID>MakeCompletionItem(v:val[1].path, v:val[0], v:val[1].path,
        \                             strftime(s:opt[s:cur_mode].time_format,
        \                                      v:val[1].time),
        \                             a:base, 1)'
        \   )
endfunction

"-----------------------------------------------------------------------------
function! <SID>CompleteDir(base)
  let patterns = map(<SID>SplitPath(a:base), '<SID>MakeFuzzyPattern(v:val)')

  echo 'Making directory list...'
  let result = filter(<SID>GlobEx(patterns[0].base, patterns[1].re, s:opt[s:cur_mode].excluded_path),
        \             'v:val =~ ''[/\\]$''')

  if len(patterns[1].base) == 0
    call insert(result, patterns[0].base)
  endif

  echo 'Evaluating...'
  call map(result, '<SID>MakeCompletionItem(v:val, -1, v:val, "", a:base, 1)')

  if len(patterns[1].base) == 0
    let result[0].word = matchstr(result[0].word, '^.*[^/\\]')
  endif

  echo 'pattern:' . patterns[0].base . patterns[1].wi . (s:opt.migemo_support ? ' + migemo' : '')

  return result
endfunction

"-----------------------------------------------------------------------------
function! <SID>CompleteTag(base)
  let patterns = <SID>MakeFuzzyPattern(a:base)

  echo 'Making tag list...'
  let result = <SID>GetTagList(patterns.re)

  echo 'Evaluating...'
  if s:opt[s:cur_mode].max_match > 0 && len(result) > s:opt[s:cur_mode].max_match
    let result = [ { 'word': (len(a:base) > 0 ? a:base : ' '),
          \          'abbr': s:opt[s:cur_mode].aborted_abbr } ]
  else
    call map(result,  '<SID>MakeCompletionItem(v:val, -1, v:val, "", a:base, 1)')
  endif

  echo 'pattern:' . patterns.wi . (s:opt.migemo_support ? ' + migemo' : '')
  return result
endfunction

"-----------------------------------------------------------------------------
function! <SID>CompleteTaggedFile(base)
  let patterns = <SID>MakeFuzzyPattern(a:base)

  echo 'Making tagged file list...'
  let result = <SID>GetTaggedFileList(patterns.re)

  echo 'Evaluating...'
  if s:opt[s:cur_mode].max_match > 0 && len(result) > s:opt[s:cur_mode].max_match
    let result = [ { 'word': (len(a:base) > 0 ? a:base : ' '),
          \          'abbr': s:opt[s:cur_mode].aborted_abbr } ]
  else
    call map(result,  '<SID>MakeCompletionItem(v:val, -1, v:val, "", a:base, 1)')
  endif

  echo 'pattern:' . patterns.wi . (s:opt.migemo_support ? ' + migemo' : '')
  return result
endfunction

"-----------------------------------------------------------------------------
function! <SID>OpenBuffer(expr, mode)
  if     a:mode == 0
    return ':buffer '            . a:expr . "\<CR>"
  elseif a:mode == 1
    return ':sbuffer '           . a:expr . "\<CR>"
  elseif a:mode == 2
    return ':vertical :sbuffer ' . a:expr . "\<CR>"
  endif
  return ""
endfunction

"-----------------------------------------------------------------------------
function! <SID>OpenFile(expr, mode)
  if      a:mode == 0
    return ':edit '   . a:expr . "\<CR>"
  elseif a:mode == 1
    return ':split '  . a:expr . "\<CR>"
  elseif a:mode == 2
    return ':vsplit ' . a:expr . "\<CR>"
  endif
  return ""
endfunction

"-----------------------------------------------------------------------------
function! <SID>OpenMruCmd(expr, mode)
  if     a:mode == 0
    call <SID>UpdateMruCmdInfo(a:expr)
    return a:expr . "\<CR>"
  elseif a:mode == 1 || a:mode == 2
    return a:expr
  endif
  return ""
endfunction

"-----------------------------------------------------------------------------
function! <SID>OpenDir(expr, mode)
  if     a:mode == 0
    return ':cd ' . a:expr . "\<CR>"
  elseif a:mode == 1 || a:mode == 2
    return ':cd ' . a:expr
  endif
  return ""
endfunction

"-----------------------------------------------------------------------------
function! <SID>OpenTag(expr, mode)
  let uni = (len(taglist('^' . a:expr . '$')) == 1)
  if      a:mode == 0
    return (uni ? ':tag ' : ':tselect ')   . a:expr . "\<CR>"
  elseif a:mode == 1
    return (uni ? ':split | :tag ' : ':stselect ')  . a:expr . "\<CR>"
  elseif a:mode == 2
    return (uni ? ':vsplit | :tag ' : ':vertical :stselect ')  . a:expr . "\<CR>"
  endif
  return ""
endfunction

"-----------------------------------------------------------------------------
" 'str' -> {'base':'str', 'wi':'*s*t*r*', 're':'\V\.\*s\.\*t\.\*r\.\*'}
function! <SID>MakeFuzzyPattern(base)
  let wi = ''
  for char in split(a:base, '\zs')
    if wi !~ '[*?]$' && char !~ '[*?]'
      let wi .= '*'. char
    else
      let wi .= char
    endif
  endfor

  if wi !~ '[*?]$'
    let wi .= '*'
  endif

  let re = '\V' . substitute(substitute(substitute(escape(wi, '\'),
        \                                          '*', '\\.\\*', 'g'),
        \                               '?', '\\.', 'g'),
        \                    '[', '\\[', 'g')

  if s:opt.migemo_support && a:base !~ '[^\x01-\x7e]'
    let re .= '\|\m.*' . substitute(migemo(a:base), '\\_s\*', '.*', 'g') . '.*'
  endif

  return { 'base': a:base, 'wi':wi, 're': re }
endfunction

"-----------------------------------------------------------------------------
function! <SID>ExpandAbbrevMap(base, abbrev_map)
  let result = [a:base]

  " expand
  for [pattern, sub_list] in items(a:abbrev_map)
    let exprs = result
    let result = []
    for expr in exprs
      let result += map(copy(sub_list), 'substitute(expr, pattern, v:val, "g")')
    endfor
  endfor

  return <SID>Unique(result)
endfunction

"-----------------------------------------------------------------------------
function <SID>Unique(in)
  let sorted = sort(a:in)

  if len(sorted) < 2
    return sorted
  endif

  let last = remove(sorted, 0)
  let result = [last]
  for item in sorted
    if item != last
      call add(result, item)
      let last = item
    endif
  endfor

  return result
endfunction

"-----------------------------------------------------------------------------
function! <SID>MakeNumberedList(in, first)
  for i in range(len(a:in))
    let a:in[i] = [i + a:first, a:in[i]]
  endfor

  return a:in
endfunction

"-----------------------------------------------------------------------------
function! <SID>ExistsPrompt(in)
  return strlen(a:in) >= strlen(s:prompt) && a:in[:strlen(s:prompt) -1] ==# s:prompt
endfunction

"-----------------------------------------------------------------------------
function! <SID>SplitPath(path)
  let dir = matchstr(a:path, '^.*[/\\]')
  return [dir, a:path[strlen(dir):]]
endfunction

"-----------------------------------------------------------------------------
function! <SID>GlobEx(dir, file, excluded)
  call extend(s:cache, { 'file' : {} }, 'keep')

  if a:dir =~ '\S'
    let key = a:dir
  else
    let key = ' '
  endif

  if !has_key(s:cache.file, key)
    if key =~ '\S'
      let dir_list = split(expand(a:dir), "\n")
    else
      let dir_list = [""]
    endif

    let s:cache.file[key] = []

    for d in dir_list
      for f in ['.*', '*']
        let s:cache.file[key] += split(glob(d . f), "\n")
      endfor 
    endfor

    if len(dir_list) <= 1
      call map(s:cache.file[key], '[a:dir, <SID>SplitPath(v:val)[1], <SID>GetPathSeparatorIfDirectory(v:val)]')
    else
      call map(s:cache.file[key], '<SID>SplitPath(v:val) + [<SID>GetPathSeparatorIfDirectory(v:val)]')
    endif

    if len(a:excluded)
      call filter(s:cache.file[key], 'v:val[0] . v:val[1] . v:val[2] !~ a:excluded')
    endif
  endif

  return map(filter(copy(s:cache.file[key]),
        \           'v:val[1] =~ a:file'),
        \    'v:val[0] . v:val[1] . v:val[2]')
endfunction

"-----------------------------------------------------------------------------
function! <SID>GetTagList(pattern)
  call extend(s:cache, { 'tag' : {} }, 'keep')
  let cur_dir = fnamemodify('.', ':p')

  " tags file updated?
  if has_key(s:cache.tag, cur_dir)
    for tagfile in tagfiles()
      if getftime(tagfile) >= s:cache.tag[cur_dir].time
        unlet s:cache.tag[cur_dir]
        break
      endif
    endfor
  endif

  if !has_key(s:cache.tag, cur_dir)
    let s:cache.tag[cur_dir] = { 'data' : [], 'time' : localtime() }
    for tagfile in tagfiles()
      let s:cache.tag[cur_dir].data += map(readfile(tagfile), 'matchstr(v:val, ''^[^!\t][^\t]*'')')
    endfor
    let s:cache.tag[cur_dir].data = <SID>Unique(s:cache.tag[cur_dir].data)
  endif

  return filter(copy(s:cache.tag[cur_dir].data), 'v:val =~ a:pattern')
endfunction

"-----------------------------------------------------------------------------
function! <SID>GetTaggedFileList(pattern)
  call extend(s:cache, { 'tagged_file' : {} }, 'keep')
  let cur_dir = fnamemodify('.', ':p')

  " tags file updated?
  if has_key(s:cache.tagged_file, cur_dir)
    for tagfile in tagfiles()
      if getftime(tagfile) >= s:cache.tagged_file[cur_dir].time
        unlet s:cache.tagged_file[cur_dir]
        break
      endif
    endfor
  endif

  if !has_key(s:cache.tagged_file, cur_dir)
    let s:cache.tagged_file[cur_dir] = { 'data' : [], 'time' : localtime() }
    for [head, tail] in map(tagfiles(), '[fnamemodify(v:val, ":p:h"), fnamemodify(v:val, ":t")]')
      execute 'cd ' . head
      let s:cache.tagged_file[cur_dir].data +=
            \ map(readfile(tail), 'fnamemodify(matchstr(v:val, ''^[^!\t][^\t]*\t\zs[^\t]\+''), ":p")')
      cd -
    endfor
    let s:cache.tagged_file[cur_dir].data = <SID>Unique(s:cache.tagged_file[cur_dir].data)
  endif

  return filter(copy(s:cache.tagged_file[cur_dir].data), 'v:val =~ a:pattern')
endfunction

"-----------------------------------------------------------------------------
function! <SID>MakeCompletionItem(expr, number_str, abbr, time, entered, evals_path_tail)
  let number = str2nr(a:number_str)
  if      (number >= 0 && str2nr(number) == str2nr(a:entered)) || (a:expr == a:entered)
    let rate = s:matching_rate_base
  elseif a:evals_path_tail
    let rate = <SID>EvaluateMatchingRate(<SID>SplitPath(matchstr(a:expr, '^.*[^/\\]'))[1],
          \                              <SID>SplitPath(a:entered)[1])
  else
    let rate = <SID>EvaluateMatchingRate(a:expr, a:entered)
  endif

  return  {
        \   'word'  : a:expr,
        \   'abbr'  : (number >= 0 ? printf('%2d: ', number) : '') . a:abbr,
        \   'menu'  : (len(a:time) ? a:time . ' ' : '') . '[' . <SID>MakeRateStars(rate, 5) . ']',
        \   'order' : [-rate, (number >= 0 ? number : a:expr)]
        \ }
endfunction

"-----------------------------------------------------------------------------
function! <SID>EvaluateMatchingRate(expr, pattern)
  if a:expr == a:pattern
    return s:matching_rate_base
  endif

  let rate = 0.0
  let rate_increment = (s:matching_rate_base * 9) / (len(a:pattern) * 10) " zero divide ok
  let matched = 1

  let i_pattern = 0
  for i_expr in range(len(a:expr))
    if a:expr[i_expr] == a:pattern[i_pattern]
      let rate += rate_increment
      let matched = 1
      let i_pattern += 1
      if i_pattern >= len(a:pattern)
        break
      endif
    elseif matched
      let rate_increment = rate_increment / 2
      let matched = 0
    endif
  endfor

  return rate
endfunction

"-----------------------------------------------------------------------------
function! <SID>MakeRateStars(rate, base)
  let len = (a:base * a:rate) / s:matching_rate_base
  return repeat('*', len) . repeat('.', a:base - len)
endfunction

"-----------------------------------------------------------------------------
function! <SID>SortByMultipleOrder(i1, i2)
  if has_key(a:i1, 'order') && has_key(a:i2, 'order')
    for i in range(min([len(a:i1.order), len(a:i2.order)]))
      if     a:i1.order[i] > a:i2.order[i]
        return +1
      elseif a:i1.order[i] < a:i2.order[i]
        return -1
      endif
    endfor
  endif
  return 0
endfunction

"-----------------------------------------------------------------------------
function! <SID>GetPathSeparatorIfDirectory(path)
  if isdirectory(a:path)
    return s:path_separator
  else
    return ''
  endif
endfunction

"-----------------------------------------------------------------------------
function! <SID>ReadInfoFile()
  try
    let lines = filter(map(readfile(expand(s:opt.info_file)),
          \                'matchlist(v:val, "^\\([^\\t]\\+\\)\\t\\(.*\\)$")'),
          \            '!empty(v:val)')
  catch /.*/ 
    return {}
  endtry

  let info = {}
  for line in lines
    if !has_key(info, line[1])
      if line[1] == 'version' && line[2] != s:info_version
        echo printf(s:msg_rm_info, expand(s:opt.info_file))
        let s:opt.info_file = ''
        return {}
      endif
      execute 'let info[line[1]] = [' . line[2] . ']'
    else
      execute 'call add(info[line[1]], ' . line[2] . ')'
    endif
  endfor

  return info
endfunction

"-----------------------------------------------------------------------------
function! <SID>WriteInfoFile(info)
  let a:info.version = [s:info_version]
  let lines = []
  for [key, value] in items(a:info)
    let lines += map(copy(value), 'key . "\t" . string(v:val)')
  endfor

  try
    call writefile(lines, expand(s:opt.info_file))
  catch /.*/ 
  endtry

endfunction

"-----------------------------------------------------------------------------
function! <SID>UpdateMruFileInfo(path)
  let s:info = <SID>ReadInfoFile()

  call extend(s:info, { 'mru_file' : [] }, 'keep')
  let s:info.mru_file = filter(insert(filter(s:info.mru_file,'v:val.path != a:path'),
        \                             { 'path' : a:path, 'time' : localtime() }),
        \                      'v:val.path !~ s:opt.mru_file.excluded_path && filereadable(v:val.path)'
        \                     )[0 : s:opt.mru_file.max_item - 1]

  call <SID>WriteInfoFile(s:info)
endfunction

"-----------------------------------------------------------------------------
function! <SID>UpdateMruCmdInfo(command)
  let s:info = <SID>ReadInfoFile()

  call extend(s:info, { 'mru_cmd' : [] }, 'keep')
  let s:info.mru_cmd = filter(insert(filter(s:info.mru_cmd,'v:val.command != a:command'),
        \                            { 'command' : a:command, 'time' : localtime() }),
        \                     'v:val.command !~ s:opt.mru_cmd.excluded_command'
        \                    )[0 : s:opt.mru_cmd.max_item - 1]

  call <SID>WriteInfoFile(s:info)
endfunction

"-----------------------------------------------------------------------------
function! <SID>UpdateFavFileInfo(in_file, adds)
  if empty(a:in_file)
    let file = expand('%:p')
  else
    let file = fnamemodify(a:in_file, ':p')
  endif

  let s:info = <SID>ReadInfoFile()

  call extend(s:info, { 'fav_file' : [] }, 'keep')
  let s:info.fav_file = filter(s:info.fav_file, 'v:val.path != file')

  if a:adds
    let s:info.fav_file = add(s:info.fav_file, { 'path' : file, 'time' : localtime() })
  endif

  call <SID>WriteInfoFile(s:info)
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EVENT HANDLER:
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"-----------------------------------------------------------------------------
function! <SID>OnBufEnter()
  if s:opt.mru_file.mode_available
    if !s:opt.mru_file.no_special_buffer || empty(&buftype)
      call <SID>UpdateMruFileInfo(expand('%:p')) " == '<afile>:p'
    endif
  endif
  return ""
endfunction

"-----------------------------------------------------------------------------
function! <SID>OnBufWritePost()
  if s:opt.mru_file.mode_available
    if !s:opt.mru_file.no_special_buffer || empty(&buftype)
      call <SID>UpdateMruFileInfo(expand('%:p')) " == '<afile>:p'
    endif
  endif
  return ""
endfunction

"-----------------------------------------------------------------------------
function! <SID>OnCursorMovedI()
  " Command prompt is removed?
  if !<SID>ExistsPrompt(getline('.'))
    call setline('.', s:prompt . getline('.'))
    return repeat("\<Right>", len(s:prompt))
  elseif col('.') <= len(s:prompt)
    return repeat("\<Right>", len(s:prompt) - col('.') + 1)
  elseif col('.') > strlen(getline('.')) && col('.') != s:last_col
    " if the cursor is placed on the end of the line and has been actually moved.
    let s:last_col = col('.')
    return "\<C-x>\<C-u>"
  endif

  return ""
endfunction

"-----------------------------------------------------------------------------
function! <SID>OnInsertLeave()
  if exists('s:reserved_switch_mode')
    let keylist = filter((s:reserved_switch_mode > 0 ? reverse(keys(s:opt)) : keys(s:opt)),
          \              'type(s:opt[v:val]) == type({}) && has_key(s:opt[v:val], ''mode_available'') && s:opt[v:val].mode_available')
    let key_last = keylist[-1]
    for key in keylist
      if key == s:cur_mode
        break
      endif
      let key_last = key
    endfor

    call <SID>OpenFuzzyFinder(key_last)
    unlet s:reserved_switch_mode
  else
    quit
  endif
  return ""
endfunction

"-----------------------------------------------------------------------------
function! <SID>OnBufLeave()
  " resume autocomplpop.vim
  if exists(':AutoComplPopUnlock')
    :AutoComplPopUnlock
  endif

  let &completeopt = s:_completeopt
  let &ignorecase  = s:_ignorecase
  unlet s:buf_nr

  quit " Quit when other window clicked without leaving a insert mode.

  if exists('s:reserved_command')
    let command = s:opt[s:cur_mode].open(s:reserved_command[0], s:reserved_command[1])
    unlet s:reserved_command
  else
    let command = ""
  endif

  " remove caches
  for key in keys(s:cache)
    if !s:opt[key].lasting_cache
      unlet s:cache[key]
    endif
  endfor
  call garbagecollect()

  return command
endfunction

"-----------------------------------------------------------------------------
function! <SID>OnCR(index, check_dir)
  if pumvisible()
    return "\<C-y>\<C-r>=" . s:sid_prefix . "OnCR('" . a:index . "'," . 1 . ")\<CR>"
  endif

  if a:check_dir && getline('.') =~ '[/\\]$'
    return ""
  endif

  if <SID>ExistsPrompt(getline('.'))
    let s:reserved_command = [getline('.')[strlen(s:prompt):], a:index]
  else
    let s:reserved_command = [getline('.')                   , a:index]
  endif

  return "\<Esc>"
endfunction

"-----------------------------------------------------------------------------
function! <SID>OnBS()
  if pumvisible()
    return "\<C-e>\<BS>"
  else
    return "\<BS>"
  endif
endfunction

"-----------------------------------------------------------------------------
function! <SID>OnSwitchMode(next_prev)
  let s:reserved_switch_mode = a:next_prev
  return "\<Esc>"
endfunction


"-----------------------------------------------------------------------------

function! <SID>OnSwitchIgnoreCase()
  let &ignorecase = !&ignorecase
  echo "ignorecase = " . &ignorecase
  let s:last_col = -1
  return <SID>OnCursorMovedI()
endfunction

"-----------------------------------------------------------------------------
function! <SID>OnCmdLineCR()
  let type = getcmdtype()
  if type == ':' || type == '/'
    call <SID>UpdateMruCmdInfo(type . getcmdline())
  endif
  return "\<CR>"
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INITIALIZE:
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call <SID>Initialize()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

