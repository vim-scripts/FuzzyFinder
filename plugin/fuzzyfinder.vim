""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" fuzzyfinder.vim : The buffer/file/MRU-files/MRU-commands/favorite-files
"                   explorer with the fuzzy pattern
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Last Change:  24-Oct-2007.
" Author:       Takeshi Nishida <ns9tks(at)ns9tks.net>
" Version:      1.4.1, for Vim 7.0
" Licence:      MIT Licence
"
"-----------------------------------------------------------------------------
" Description:
"   Fuzzyfinder provides convenient ways to quickly reach the
"   buffer/file/command you want. Fuzzyfinder finds matching
"   files/buffers/commands with a fuzzy pattern to which it converted the
"   inputting pattern.
"
"   Fuzzyfinder has 5 modes:
"       - Buffer mode
"       - File mode
"       - MRU-files mode (most recently used files)
"       - MRU-commands mode (most recently used commands)
"       - Favorite-files mode
"
"   E.g.: the inputting pattern / the fuzzy pattern
"       abc      -> *a*b*c*
"       a?c      -> *a?c*         (? matches one character.)
"       dir/file -> dir/*f*i*l*e*
"       d*r/file -> d*r/*f*i*l*e*
"       ../**/s  -> ../**/*s*     (** allows searching a directory tree.)
"
"   You will be happy when:
"       "./OhLongLongLongLongLongFile.txt"
"       "./AhLongLongLongLongLongName.txt"
"       "./AhLongLongLongLongLongFile.txt" <- you want :O
"       Type "AF" and "AhLongLongLongLongLongFile.txt" will be select. :D
"
"   Fuzzyfinder supports the multibyte.
"
"-----------------------------------------------------------------------------
" Installation:
"   Drop this file in your plugin directory.  If you have installed
"   autocomplpop.vim (vimscript #1879), please update to the latest version
"   to prevent interference.
"
"-----------------------------------------------------------------------------
" Usage:
"   Starting The Explorer:
"       You can start the explorer by the following commands:
"
"           :FuzzyFinderBuffer      - launchs the buffer explorer.
"           :FuzzyFinderFile        - launchs the file explorer.
"           :FuzzyFinderMruFile     - launchs the MRU-files explorer.
"           :FuzzyFinderMruCmd      - launchs the MRU-commands explorer.
"           :FuzzyFinderFavFile     - launchs the favorite-files explorer.
"
"       It is recommended to map these. Personally, I map <C-n> to
"       :FuzzyFinderBuffer and <C-p> to :FuzzyFinderFile.
"
"   In The Explorer:
"       The inputting pattern you typed is converted to the fuzzy pattern and
"       buffers/files which match the pattern is shown in a completion menu.
"
"       A completion menu is shown when you type at the end of the line and
"       the length of inputting pattern is more than setting value. By
"       default, it is shown at the beginning.
"
"       If too many items (400, by default) were matched, the completion is
"       aborted to reduce nonresponse.
"
"       If inputting pattern matched the item perfectly, the item is shown
"       first. Same applies to the item number in the buffer/MRU/favorite
"       mode. The item whose file name has longer prefix matching is placed
"       upper. The item which matched more sequentially is placed upper. It
"       lets the first item into selected in completion menu.
"
"       Pressing <CR> opens selected item in previous window. If selected item
"       was a directory in the file mode, it just inserts text. Use <F1> to
"       open in new window which is made from split previous window, or <F2>
"       To open in new window which is made from split previous window
"       vertically. In MRU-commands mode, press <CR> and it executes selected
"       command, or press <F1>/<F2> and it just puts text into the
"       command-line. These key mappings are customizable.
"
"       To cancel and return to previous window, leave the insert mode.
"
"       To Switch the mode without leaving a insert mode, use <F12>. This key
"       mapping is customizable.
"
"       If you want to temporarily change whether or not to ignore case, use
"       <F11>. This key mapping is customizable.
"
"   About Abbreviations And Multiple Search:
"       You can use abbreviations and multiple search in each mode. For
"       example, set as below:
"
"           :let g:FuzzyFinder_FileModeVars =
"                       \ { "abbrevMap" :
"                       \   { "^WORK" : [ "~/project/**/src/",
"                       \                 ".vim/plugin/"
"                       \               ]
"                       \   }
"                       \ }
"
"       And input "WORKtxt" in the file-mode explorer, then it searches by
"       following patterns:
"
"           "~/project/**/src/*t*x*t*"
"           ".vim/plugin/*t*x*t*"
"
"   Adding Favorite Files:
"       You can add a favorite file by the following commands:
"
"           :FuzzyFinderAddFavFile {filename}
"
"       If you do not specify the filename, current file name is used.
"
"   About Information File:
"       Fuzzyfinder writes information of the MRU, favorite, etc to the file
"       by default (~/.vimfuzzyfinder). If you don't want the file, set as
"       below:
"
"           :let g:FuzzyFinder_InfoFile = ""
"
"   About Migemo:
"       Migemo is a search method for Japanese language.
"
"   About Adding Original Mode:
"       This feature is UNDERSPECIFIED. You can add original mode by
"       :FuzzyFinderAddMode command. To start the explorer with original mode,
"       use :FuzzyFinder command.
"
"-----------------------------------------------------------------------------
" Options:
"   g:FuzzyFinder_InfoFile:
"       This is the file name to write information of the MRU, etc. If "" was
"       set, it does not write to the file.
"
"   g:FuzzyFinder_KeyOpen:
"       This is a list. These are mapped to select completion item or to
"       finish input and open a buffer/file.
"       [0]:
"           This is mapped to open in previous window.
"       [1]:
"           This is mapped to open in new window which is made from split
"           previous window.
"       [2]:
"           This is mapped to open in new window which is made from split
"           previous window vertically.
"
"   g:FuzzyFinder_KeySwitchMode:
"       This is mapped to switch the mode in insert mode.
"
"   g:FuzzyFinder_KeySwitchIgnoreCase:
"       This is mapped to temporarily switch whether or not to ignore case.
"
"   g:FuzzyFinder_IgnoreCase:
"       It ignores case in search patterns if non-zero is set.
"
"   g:FuzzyFinder_Migemo:
"       It uses Migemo if non-zero is set.
"
"   g:FuzzyFinder_BufferModeVars:
"       This is a dictionary. This applies only to buffer mode.
"       "initialInput":
"           This is a text which is inserted at the beginning of the mode.
"       "abbrevMap"
"           This is a dictionary. Each value must be a list. All matchs of a
"           key in inputting text is expanded with a value. 
"       "minLength":
"           It does not complete if a length of inputting is less than this.
"       "excludedIndicator":
"           Items whose indicators match this are excluded.
"
"   g:FuzzyFinder_FileModeVars:
"       This is a dictionary. This applies only to mode.
"       "initialInput":
"           This is a text which is inserted at the beginning of the mode.
"       "abbrevMap"
"           This is a dictionary. Each value must be a list. All matchs of a
"           key in inputting text is expanded with a value. 
"       "minLength":
"           It does not complete if a length of inputting is less than this.
"       "excludedPath":
"           Items whose paths match this are excluded.
"       "maxMatches":
"           If items were matched over this, processing completion is aborted.
"           If 0 was set, it does not limit.
"
"   g:FuzzyFinder_MruFileModeVars:
"       This is a dictionary. This applies only to the MRU-files mode.
"       "initialInput":
"           This is a text which is inserted at the beginning of the mode.
"       "abbrevMap"
"           This is a dictionary. Each value must be a list. All matchs of a
"           key in inputting text is expanded with a value. 
"       "minLength":
"           It does not complete if a length of inputting is less than this.
"       "excludedPath":
"           Items whose paths match this are excluded.
"       "ignoreSpecialBuffers"
"           It ignores special buffers if non-zero is set.
"       "maxItems":
"           This is an upper limit of MRU files to be stored. If 0 was set, it
"           does not limit.
"
"   g:FuzzyFinder_MruCmdModeVars:
"       This is a dictionary. This applies only to the MRU-commands mode.
"       "initialInput":
"           This is a text which is inserted at the beginning of the mode.
"       "abbrevMap"
"           This is a dictionary. Each value must be a list. All matchs of a
"           key in inputting text is expanded with a value. 
"       "minLength":
"           It does not complete if a length of inputting is less than this.
"       "excludedCommand":
"           Items whose commands match this are excluded.
"       "maxItems":
"           This is an upper limit of MRU commands to be stored. If 0 was set,
"           it does not limit.
"
"   g:FuzzyFinder_FavFileModeVars:
"       This is a dictionary. This applies only to the favorite-files mode.
"       "initialInput":
"           This is a text which is inserted at the beginning of the mode.
"       "abbrevMap"
"           This is a dictionary. Each value must be a list. All matchs of a
"           key in inputting text is expanded with a value. 
"       "minLength":
"           It does not complete if a length of inputting is less than this.
"
"-----------------------------------------------------------------------------
" Settings Example:
"   My settings for gvim:
"       :let g:FuzzyFinder_KeyOpen = ['<CR>', '<C-CR>', '<S-C-CR>']
"       :let g:FuzzyFinder_KeySwitchMode = '<TAB>'
"       :let g:FuzzyFinder_KeySwitchIgnoreCase = '<C-TAB>'
"       :let g:FuzzyFinder_FileModeVars =
"                   \ { 'abbrevMap' : { '\C^VP' : ['$VIM/runtime/plugin/' ,
"                   \                              '$VIM/vimfiles/plugin/',
"                   \                              '~/vim/plugin'],
"                   \                   '\C^VC' : ['$VIM/runtime/colors/' ,
"                   \                              '$VIM/vimfiles/colors/',
"                   \                              '~/vim/colors']}
"                   \ }
"       :let g:FuzzyFinder_MruFileModeVars = { 'maxItems' : 99 }
"       :let g:FuzzyFinder_MruCmdModeVars  = { 'maxItems' : 99 }
"       :nnoremap <C-n>      :FuzzyFinderBuffer<CR>
"       :nnoremap <C-p>      :FuzzyFinderFile<CR>
"       :nnoremap <C-f><C-n> :FuzzyFinderMruFile<CR>
"       :nnoremap <C-f><C-p> :FuzzyFinderMruCmd<CR>
"       :nnoremap <C-f><C-f> :FuzzyFinderFavFile<CR>
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
"   1.4:
"       - Changed the specification of the information file.
"       - Added the MRU-commands mode.
"       - Renamed :FuzzyFinderAddFavorite command to :FuzzyFinderAddFavFile.
"       - Renamed g:FuzzyFinder_MruModeVars option to
"         g:FuzzyFinder_MruFileModeVars.
"       - Renamed g:FuzzyFinder_FavoriteModeVars option to
"         g:FuzzyFinder_FavFileModeVars.
"       - Changed to show registered time of each item in MRU/favorite mode.
"       - Added 'timeFormat' option for MRU/favorite modes.
"
"   1.3:
"       - Fixed a handling of multi-byte characters.
"
"   1.2:
"       - Added support for Migemo. (Migemo is Japanese search method.)
"
"   1.1:
"       - Added the favorite mode.
"       - Added new features, which are abbreviations and multiple search.
"       - Added 'abbrevMap' option for each mode.
"       - Added g:FuzzyFinder_MruModeVars['ignoreSpecialBuffers'] option.
"       - Fixed the bug that it did not work correctly when a user have mapped
"         <C-p> or <Down>.
"
"   1.0:
"       - Added the MRU mode.
"       - Added commands to add and use original mode.
"       - Improved the sorting algorithm for completion items.
"       - Added 'initialInput' option to automatically insert a text at the
"         beginning of a mode.
"       - Changed that 'excludedPath' option works for the entire path.
"       - Renamed some options. 
"       - Changed default values of some options. 
"       - Packed the mode-specific options to dictionaries.
"       - Removed some options.
"
"   0.6:
"       - Fixed some bugs.

"   0.5:
"       - Improved response by aborting processing too many items.
"       - Changed to be able to open a buffer/file not only in previous window
"         but also in new window.
"       - Fixed a bug that recursive searching with '**' does not work.
"       - Added g:FuzzyFinder_CompletionItemLimit option.
"       - Added g:FuzzyFinder_KeyOpen option.
"
"   0.4:
"       - Improved response of the input.
"       - Improved the sorting algorithm for completion items. It is based on
"         the matching level. 1st is perfect matching, 2nd is prefix matching,
"         and 3rd is fuzzy matching.
"       - Added g:FuzzyFinder_ExcludePattern option.
"       - Removed g:FuzzyFinder_WildIgnore option.
"       - Removed g:FuzzyFinder_EchoPattern option.
"       - Removed g:FuzzyFinder_PathSeparator option.
"       - Changed the default value of g:FuzzyFinder_MinLengthFile from 1 to
"         0.
"
"   0.3:
"       - Added g:FuzzyFinder_IgnoreCase option.
"       - Added g:FuzzyFinder_KeyToggleIgnoreCase option.
"       - Added g:FuzzyFinder_EchoPattern option.
"       - Changed the open command in a buffer mode from ":edit" to ":buffer"
"         to avoid being reset cursor position.
"       - Changed the default value of g:FuzzyFinder_KeyToggleMode from
"         <C-Space> to <F12> because <C-Space> does not work on some CUI
"         environments.
"       - Changed to avoid being loaded by Vim before 7.0.
"       - Fixed a bug with making a fuzzy pattern which has '\'.
"
"   0.2:
"       - A bug it does not work on Linux is fixed.
"
"   0.1:
"       - First release.
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
    let s:aborted_result = [{'word': ' ', 'abbr': 'ABORT: Too many matches (> g:FuzzyFinder_FileModeVars.maxMatches)'}]
    let s:matching_rate_base = 10000000
    let s:sid_prefix = matchstr(expand('<sfile>'), '<SNR>\d\+_')
    let s:msg_rm_info = "==================================================\n" .
                \       "  Your fuzzyfinder information file is no longer \n"  .
                \       "  supported. Please remove\n"                         .
                \       "  \"%s\".\n"                                          .
                \       "=================================================="
    "-------------------------------------------------------------------------
    " OPTIONS
    if !exists('g:FuzzyFinder_InfoFile')
        let g:FuzzyFinder_InfoFile = '~/.vimfuzzyfinder'
    endif
    ".........................................................................
    if !exists('g:FuzzyFinder_KeyOpen')
        let g:FuzzyFinder_KeyOpen = ['<CR>', '<F1>', '<F2>']
    endif
    ".........................................................................
    if !exists('g:FuzzyFinder_KeySwitchMode')
        let g:FuzzyFinder_KeySwitchMode = '<F12>'
    endif
    ".........................................................................
    if !exists('g:FuzzyFinder_KeySwitchIgnoreCase')
        let g:FuzzyFinder_KeySwitchIgnoreCase = '<F11>'
    endif
    ".........................................................................
    if !exists('g:FuzzyFinder_IgnoreCase')
        let g:FuzzyFinder_IgnoreCase = &ignorecase
    endif
    ".........................................................................
    if !exists('g:FuzzyFinder_Migemo')
        let g:FuzzyFinder_Migemo = has('migemo')
    endif
    ".........................................................................
    if !exists('g:FuzzyFinder_BufferModeVars')
        let g:FuzzyFinder_BufferModeVars = {}
    endif
    call extend(g:FuzzyFinder_BufferModeVars,
                \ { 'name'                 : 'buffer',
                \   'bufferName'           : '[FuzzyFinder - Buffer]',
                \   'complete'             : function('<SID>CompleteBuffer'),
                \   'open'                 : function('<SID>OpenBuffer'),
                \   'initialInput'         : '',
                \   'abbrevMap'            : {},
                \   'minLength'            : 0,
                \   'excludedIndicator'    : '[u\-]',
                \ } ,'keep')
    ".........................................................................
    if !exists('g:FuzzyFinder_FileModeVars')
        let g:FuzzyFinder_FileModeVars = {}
    endif
    call extend(g:FuzzyFinder_FileModeVars,
                \ { 'name'                 : 'file',
                \   'bufferName'           : '[FuzzyFinder - File]',
                \   'complete'             : function('<SID>CompleteFile'),
                \   'open'                 : function('<SID>OpenFile_MruFile_FavFile'),
                \   'initialInput'         : '',
                \   'abbrevMap'            : {},
                \   'minLength'            : 0,
                \   'excludedPath'         : '\v\~$|\.bak$|\.swp$|((^|[/\\])\.[/\\]$)',
                \   'maxMatches'           : 400,
                \ } ,'keep')
    ".........................................................................
    if !exists('g:FuzzyFinder_MruFileModeVars')
        let g:FuzzyFinder_MruFileModeVars = {}
    endif
    call extend(g:FuzzyFinder_MruFileModeVars,
                \ { 'name'                 : 'mru_file',
                \   'bufferName'           : '[FuzzyFinder - MRU-Files]',
                \   'complete'             : function('<SID>CompleteMruFile'),
                \   'open'                 : function('<SID>OpenFile_MruFile_FavFile'),
                \   'initialInput'         : '',
                \   'abbrevMap'            : {},
                \   'minLength'            : 0,
                \   'excludedPath'         : '\v\~$|\.bak$|\.swp$',
                \   'ignoreSpecialBuffers' : 1,
                \   'timeFormat'           : '(%x %H:%M:%S)',
                \   'maxItems'             : 20,
                \ } ,'keep')
    ".........................................................................
    if !exists('g:FuzzyFinder_MruCmdModeVars')
        let g:FuzzyFinder_MruCmdModeVars = {}
    endif
    call extend(g:FuzzyFinder_MruCmdModeVars,
                \ { 'name'                 : 'mru_cmd',
                \   'commandFormat'        : ["%s\<CR>", "%s", "%s"],
                \   'bufferName'           : '[FuzzyFinder - MRU-Commands]',
                \   'complete'             : function('<SID>CompleteMruCmd'),
                \   'open'                 : function('<SID>OpenMruCmd'),
                \   'initialInput'         : '',
                \   'abbrevMap'            : {},
                \   'minLength'            : 0,
                \   'excludedCommand'      : '^.\{0,4}$',
                \   'timeFormat'           : '(%x %H:%M:%S)',
                \   'maxItems'             : 20,
                \ } ,'keep')
    ".........................................................................
    if !exists('g:FuzzyFinder_FavFileModeVars')
        let g:FuzzyFinder_FavFileModeVars = {}
    endif
    call extend(g:FuzzyFinder_FavFileModeVars,
                \ { 'name'                 : 'fav_file',
                \   'bufferName'           : '[FuzzyFinder - Favorite-Files]',
                \   'complete'             : function('<SID>CompleteFavFile'),
                \   'open'                 : function('<SID>OpenFile_MruFile_FavFile'),
                \   'initialInput'         : '',
                \   'abbrevMap'            : {},
                \   'minLength'            : 0,
                \   'timeFormat'           : '(%x %H:%M:%S)',
                \ } ,'keep')
    ".........................................................................

    "-------------------------------------------------------------------------
    " COMMANDS
    command! -bar -narg=0                FuzzyFinderBuffer     call <SID>OpenFuzzyFinder(g:FuzzyFinder_BufferModeVars.name)
    command! -bar -narg=0                FuzzyFinderFile       call <SID>OpenFuzzyFinder(g:FuzzyFinder_FileModeVars.name)
    command! -bar -narg=0                FuzzyFinderMruFile    call <SID>OpenFuzzyFinder(g:FuzzyFinder_MruFileModeVars.name)
    command! -bar -narg=0                FuzzyFinderMruCmd     call <SID>OpenFuzzyFinder(g:FuzzyFinder_MruCmdModeVars.name)
    command! -bar -narg=0                FuzzyFinderFavFile    call <SID>OpenFuzzyFinder(g:FuzzyFinder_FavFileModeVars.name)
    command! -bar -narg=1                FuzzyFinder           call <SID>OpenFuzzyFinder(<args>)
    command! -bar -narg=1                FuzzyFinderAddMode    call <SID>AddMode(<args>)
    command! -bar -narg=? -complete=file FuzzyFinderAddFavFile call <SID>UpdateFavFileInfo(<q-args>, 1)

    "-------------------------------------------------------------------------
    " AUTOCOMMANDS
        augroup FuzzyFinder_GlobalAutoCommand
            autocmd!
            autocmd BufEnter     * call <SID>OnBufEnter()
            autocmd BufWritePost * call <SID>OnBufWritePost()
        augroup END

    "-------------------------------------------------------------------------
    " MAPPING
    cnoremap <silent> <expr> <CR> <SID>OnCmdLineCR()

    "-------------------------------------------------------------------------
    " ETC
    let s:info = <SID>ReadInfoFile()
    call <SID>AddMode(g:FuzzyFinder_BufferModeVars )
    call <SID>AddMode(g:FuzzyFinder_FileModeVars   )
    call <SID>AddMode(g:FuzzyFinder_MruFileModeVars)
    call <SID>AddMode(g:FuzzyFinder_MruCmdModeVars )
    call <SID>AddMode(g:FuzzyFinder_FavFileModeVars)

endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FUNCTIONS:
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"-----------------------------------------------------------------------------
function! <SID>OpenFuzzyFinder(mode)
    let s:info = <SID>ReadInfoFile()
    let s:vars_current = s:vars[a:mode]
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
        let &ignorecase = g:FuzzyFinder_IgnoreCase

        ".....................................................................
        " local setting
        setlocal bufhidden=wipe
        setlocal buftype=nofile
        setlocal noswapfile
        setlocal nobuflisted
        setlocal modifiable
        let &l:completefunc = s:sid_prefix . 'Complete'


        ".....................................................................
        " autocommands
        augroup FuzzyFinder_LocalAutoCommand
            autocmd!
            autocmd CursorMovedI <buffer>        call feedkeys(<SID>OnCursorMovedI(), 'n')
            autocmd InsertLeave  <buffer> nested call feedkeys(<SID>OnInsertLeave() , 'n')
            autocmd BufLeave     <buffer>        call feedkeys(<SID>OnBufLeave()    , 'n')
        augroup END

        ".....................................................................
        " mapping
        let i = 0 | while i < len(g:FuzzyFinder_KeyOpen)
            execute "inoremap <buffer> <silent> <expr> " . g:FuzzyFinder_KeyOpen[i]          . " <SID>OnCR(". i. ", 0)"
            let i += 1
        endwhile
        execute     "inoremap <buffer> <silent> <expr> " . "<BS>"                            . " <SID>OnBS()"
        execute     "inoremap <buffer> <silent> <expr> " . g:FuzzyFinder_KeySwitchMode       . " <SID>OnSwitchMode()"
        execute     "inoremap <buffer> <silent> <expr> " . g:FuzzyFinder_KeySwitchIgnoreCase . " <SID>OnSwitchIgnoreCase()"

    endif

    execute 'file ' . s:vars_current.bufferName

    " Starts insert mode and makes CursorMovedI event now. Command prompt is
    " needed to forces a completion menu to update every typing.
    call feedkeys('i' . s:prompt . s:vars_current.initialInput, 'n')
endfunction

"-----------------------------------------------------------------------------
function! <SID>AddMode(new_vars)
    if !exists('s:vars')
        let s:vars = {}
    endif

    if has_key(s:vars, a:new_vars.name)
        let s:vars[a:new_vars.name] = a:new_vars
    else
        let s:vars[a:new_vars.name] = a:new_vars
        if exists('s:last_added_key')
            let s:vars[a:new_vars.name ].nextMode = s:vars[s:last_added_key].nextMode
            let s:vars[s:last_added_key].nextMode = a:new_vars.name
            let s:last_added_key = a:new_vars.name
        else
            let s:vars[a:new_vars.name].nextMode = a:new_vars.name
            let s:last_added_key = a:new_vars.name
        endif
    endif
endfunction

"-----------------------------------------------------------------------------
function! <SID>Complete(findstart, base)
    if a:findstart
        return 0
    endif

    if !<SID>ExistsPrompt(a:base)
        return []
    endif

    let result = []
    for expanded_base in <SID>ExpandAbbrevMap(a:base[strlen(s:prompt):], s:vars_current.abbrevMap)
        let result += s:vars_current.complete(expanded_base)
    endfor

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

    if strlen(a:base) < s:vars_current.minLength
        return []
    endif

    redir => buffers | silent buffers! | redir END

    echo 'pattern:' . patterns.wi . (g:FuzzyFinder_Migemo ? ' + migemo' : '')

    let matchlist_pattern = '^\s*\(\d*\)\([^"]*\)"\([^"]*\)".*$'
    return     map(filter(map(split(buffers, "\n"),
                \             'matchlist(v:val, matchlist_pattern)'),
                \         'v:val[1] != s:buf_nr && v:val[2] !~ s:vars_current.excludedIndicator && ' .
                \         '(v:val[1] == patterns.base || v:val[3] =~ patterns.re)'),
                \  '<SID>MakeCompletionItem(v:val[3], v:val[1], v:val[2] . v:val[3], "", a:base, 1)'
                \ )
endfunction

"-----------------------------------------------------------------------------
function! <SID>CompleteFile(base)
    let patterns = map(<SID>SplitPath(a:base), '<SID>MakeFuzzyPattern(v:val)')

    if strlen(patterns[1].base) < s:vars_current.minLength
        return []
    endif

    echo 'Making file list...'
    let result = <SID>GlobEx(patterns[0].base, patterns[1].re, s:vars_current.excludedPath)

    echo 'Evaluating...'
    if g:FuzzyFinder_FileModeVars.maxMatches > 0 && len(result) > g:FuzzyFinder_FileModeVars.maxMatches
        let result = s:aborted_result
    else
        call map(result, '<SID>MakeCompletionItem(v:val, -1, v:val, "", a:base, 1)')
    endif

    echo 'pattern:' . patterns[0].base . patterns[1].wi . (g:FuzzyFinder_Migemo ? ' + migemo' : '')

    return result
endfunction

"-----------------------------------------------------------------------------
function! <SID>CompleteMruFile(base)
    let patterns = <SID>MakeFuzzyPattern(a:base)

    if strlen(a:base) < s:vars_current.minLength || !has_key(s:info, g:FuzzyFinder_MruFileModeVars.name)
        return []
    endif

    echo 'pattern:' . patterns.wi . (g:FuzzyFinder_Migemo ? ' + migemo' : '')

    return     map(filter(<SID>MakeNumberedList(copy(s:info[g:FuzzyFinder_MruFileModeVars.name]), 1),
                \         'v:val[0] == patterns.base || v:val[1].path =~ patterns.re'),
                \  '<SID>MakeCompletionItem(v:val[1].path, v:val[0], v:val[1].path,
                \                           strftime(g:FuzzyFinder_MruFileModeVars.timeFormat,
                \                                    v:val[1].time),
                \                           a:base, 1)'
                \ )
endfunction

"-----------------------------------------------------------------------------
function! <SID>CompleteMruCmd(base)
    let patterns = <SID>MakeFuzzyPattern(a:base)

    if strlen(a:base) < s:vars_current.minLength || !has_key(s:info, g:FuzzyFinder_MruCmdModeVars.name)
        return []
    endif

    echo 'pattern:' . patterns.wi . (g:FuzzyFinder_Migemo ? ' + migemo' : '')

    return     map(filter(<SID>MakeNumberedList(copy(s:info[g:FuzzyFinder_MruCmdModeVars.name]), 1),
                \         'v:val[0] == patterns.base || v:val[1].command =~ patterns.re'),
                \  '<SID>MakeCompletionItem(v:val[1].command, v:val[0], v:val[1].command,
                \                           strftime(g:FuzzyFinder_MruCmdModeVars.timeFormat,
                \                                    v:val[1].time),
                \                           a:base, 0)'
                \ )
endfunction

"-----------------------------------------------------------------------------
function! <SID>CompleteFavFile(base)
    let patterns = <SID>MakeFuzzyPattern(a:base)

    if strlen(a:base) < s:vars_current.minLength || !has_key(s:info, g:FuzzyFinder_FavFileModeVars.name)
        return []
    endif

    echo 'pattern:' . patterns.wi . (g:FuzzyFinder_Migemo ? ' + migemo' : '')

    return     map(filter(<SID>MakeNumberedList(copy(s:info[g:FuzzyFinder_FavFileModeVars.name]), 1),
                \         'v:val[0] == patterns.base || v:val[1].path =~ patterns.re'),
                \  '<SID>MakeCompletionItem(v:val[1].path, v:val[0], v:val[1].path,
                \                           strftime(g:FuzzyFinder_FavFileModeVars.timeFormat,
                \                                    v:val[1].time),
                \                           a:base, 1)'
                \ )
endfunction

"-----------------------------------------------------------------------------
function! <SID>OpenBuffer(expr, mode)
    if      a:mode == 0
        return ':buffer '            . a:expr . "\<CR>"
    elseif a:mode == 1
        return ':sbuffer '           . a:expr . "\<CR>"
    elseif a:mode == 2
        return ':vertical :sbuffer ' . a:expr . "\<CR>"
    endif
    return ""
endfunction

"-----------------------------------------------------------------------------
function! <SID>OpenFile_MruFile_FavFile(expr, mode)
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
    if      a:mode == 0
        call <SID>UpdateMruCmdInfo(a:expr)
        return a:expr . "\<CR>"
    elseif a:mode == 1 || a:mode == 2
        return a:expr
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
                \                                    '*', '\\.\\*', 'g'),
                \                         '?', '\\.', 'g'),
                \              '[', '\\[', 'g')

    if g:FuzzyFinder_Migemo && a:base !~ '[^\x01-\x7e]'
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
    let result = []
    " unique
    let i_in = 0 | while i_in < len(a:in)
        let i_result = 0 | while i_result < len(result)
            if a:in[i_in] == result[i_result]
                break
            endif

            let i_result += 1
        endwhile

        if i_result == len(result)
            call add(result, a:in[i_in])
        endif

        let i_in += 1
    endwhile

    return result
endfunction

"-----------------------------------------------------------------------------
function! <SID>MakeNumberedList(in, first)
    let i = 0
    while i < len(a:in)
        let a:in[i] = [i + a:first, a:in[i]]
        let i += 1
    endwhile

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
    if !exists('s:glob_ex_caches')
        let s:glob_ex_caches = {}
    endif

    if a:dir =~ '\S'
        let key = a:dir
    else
        let key = ' '
    endif

    if !has_key(s:glob_ex_caches, key)
        if key =~ '\S'
            let dir_list = split(expand(a:dir), "\n")
        else
            let dir_list = [""]
        endif

        let s:glob_ex_caches[key] = []

        for d in dir_list
            for f in ['.*', '*']
                let s:glob_ex_caches[key] += split(glob(d . f), "\n")
            endfor 
        endfor

        if len(dir_list) <= 1
            call map(s:glob_ex_caches[key], '[a:dir, <SID>SplitPath(v:val)[1], <SID>GetPathSeparatorIfDirectory(v:val)]')
        else
            call map(s:glob_ex_caches[key], '<SID>SplitPath(v:val) + [<SID>GetPathSeparatorIfDirectory(v:val)]')
        endif

        call filter(s:glob_ex_caches[key], 'v:val[0] . v:val[1] . v:val[2] !~ a:excluded')
    endif

    return    map(filter(copy(s:glob_ex_caches[key]),
                \        'v:val[1] =~ a:file'),
                \ 'v:val[0] . v:val[1] . v:val[2]')
endfunction

"-----------------------------------------------------------------------------
function! <SID>ClearGlobExCache()
    unlet! s:glob_ex_caches
endfunction

"-----------------------------------------------------------------------------
function! <SID>MakeCompletionItem(expr, number, abbr, time, input, evals_path_tail)
    if (a:number >= 0 && str2nr(a:number) == str2nr(a:input))
        let rate = s:matching_rate_base
    else
        if a:evals_path_tail
            let rate = <SID>EvaluateMatchingRate(<SID>SplitPath(matchstr(a:expr , '^.*[^/\\]'))[1],
                        \                        <SID>SplitPath(a:input)[1])
        else
            let rate = <SID>EvaluateMatchingRate(a:expr, a:input)
        endif
    endif

    return      { 'word'  : a:expr,
                \ 'abbr'  : (a:number >= 0 ? printf('%2d: ', a:number) : '') . a:abbr,
                \ 'menu'  : (len(a:time) ? a:time . ' ' : '') . '[' . <SID>MakeRateStars(rate, 5) . ']',
                \ 'order' : [-rate, (a:number >= 0 ? a:number : a:expr)]}
endfunction

"-----------------------------------------------------------------------------
function! <SID>EvaluateMatchingRate(expr, pattern)
    if a:expr == a:pattern
        return s:matching_rate_base
    endif

    let rate = 0.0
    let rate_increment = (s:matching_rate_base * 9) / (len(a:pattern) * 10) " zero divide ok
    let matched = 1
    let i0 = 0 | let i1 = 0 | while i0 < len(a:expr) && i1 < len(a:pattern)
        if a:expr[i0] == a:pattern[i1]
            let i1 += 1
            let rate += rate_increment
            let matched = 1
        elseif matched
            let rate_increment = rate_increment / 2
            let matched = 0
        endif
        let i0 += 1
    endwhile

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
        let i = 0 | while i < len(a:i1.order) && i < len(a:i2.order)
            if     a:i1.order[i] > a:i2.order[i]
                return +1
            elseif a:i1.order[i] < a:i2.order[i]
                return -1
            endif
            let i += 1
        endwhile
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
        let lines = filter(map(readfile(expand(g:FuzzyFinder_InfoFile)),
                    \          'matchlist(v:val, "^\\([^\\t]\\+\\)\\t\\(.*\\)$")'),
                    \      '!empty(v:val)')
    catch /.*/ 
        return {}
    endtry

    let info = {}
    for line in lines
        if !has_key(info, line[1])
            if line[1] == 'version' && line[2] != s:info_version
                echo printf(s:msg_rm_info, expand(g:FuzzyFinder_InfoFile))
                let g:FuzzyFinder_InfoFile = ''
                return {}
            endif
            execute('let info[line[1]] = [' . line[2] . ']')
        else
            execute('call add(info[line[1]], ' . line[2] . ')')
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
        call writefile(lines, expand(g:FuzzyFinder_InfoFile))
    catch /.*/ 
    endtry

endfunction

"-----------------------------------------------------------------------------
function! <SID>UpdateMruFileInfo(path)
    let s:info = <SID>ReadInfoFile()

    if !has_key(s:info, 'mru_file')
        let s:info.mru_file = []
    endif

    let s:info.mru_file = filter(insert(filter(s:info.mru_file,'v:val.path != a:path'),
                \                  { 'path' : a:path, 'time' : localtime() }),
                \           'v:val.path !~ g:FuzzyFinder_MruFileModeVars.excludedPath && filereadable(v:val.path)'
                \          )[0 : g:FuzzyFinder_MruFileModeVars.maxItems - 1]

    call <SID>WriteInfoFile(s:info)
endfunction

"-----------------------------------------------------------------------------
function! <SID>UpdateMruCmdInfo(command)
    let s:info = <SID>ReadInfoFile()

    if !has_key(s:info, 'mru_cmd')
        let s:info.mru_cmd = []
    endif

    let s:info.mru_cmd = filter(insert(filter(s:info.mru_cmd,'v:val.command != a:command'),
                \                  { 'command' : a:command, 'time' : localtime() }),
                \           'v:val.command !~ g:FuzzyFinder_MruCmdModeVars.excludedCommand'
                \          )[0 : g:FuzzyFinder_MruCmdModeVars.maxItems - 1]

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

    if !has_key(s:info, 'fav_file')
        let s:info.fav_file = []
    endif

    let s:info.fav_file = filter(s:info.fav_file, 'v:val.path != file')

    if a:adds
        let s:info.fav_file = add(s:info.fav_file,
                    \             { 'path' : file, 'time' : localtime() })
    endif

    call <SID>WriteInfoFile(s:info)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EVENT HANDLER:
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"-----------------------------------------------------------------------------
function! <SID>OnBufEnter()
    if !g:FuzzyFinder_MruFileModeVars.ignoreSpecialBuffers || empty(&buftype)
        call <SID>UpdateMruFileInfo(expand('%:p')) " == '<afile>:p'
    endif
    return ""
endfunction

"-----------------------------------------------------------------------------
function! <SID>OnBufWritePost()
    if !g:FuzzyFinder_MruFileModeVars.ignoreSpecialBuffers || empty(&buftype)
        call <SID>UpdateMruFileInfo(expand('%:p')) " == '<afile>:p'
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
        call <SID>OpenFuzzyFinder(s:vars_current.nextMode)
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

    call <SID>ClearGlobExCache()

    let &completeopt = s:_completeopt
    let &ignorecase  = s:_ignorecase
    unlet s:buf_nr

    quit " Quit when other window clicked without leaving a insert mode.

    if exists('s:reserved_command')
        let command = s:vars_current.open(s:reserved_command[0], s:reserved_command[1])
        unlet s:reserved_command
    else
        let command = ""
    endif

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

    "let s:reserved_command = printf(s:vars_current.commandFormat[a:index], s:reserved_command)

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
function! <SID>OnSwitchMode()
    let s:reserved_switch_mode = 1
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

