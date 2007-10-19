""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" fuzzyfinder.vim : The buffer/file/MRU/favorite explorer with the fuzzy pattern
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Last Change:  19-Oct-2007.
" Author:       Takeshi Nishida <ns9tks(at)ns9tks.net>
" Version:      1.3, for Vim 7.0
" Licence:      MIT Licence
"
"-----------------------------------------------------------------------------
" Description:
"   Fuzzyfinder provides convenient ways to quickly reach the buffer/file you
"   want. Fuzzyfinder finds matching files/buffers with a fuzzy pattern to
"   which it converted the inputting pattern.
"
"   E.g.: the inputting pattern / the fuzzy pattern
"       abc -> *a*b*c*
"       a*b*c* -> *a*b*c*
"       a?b*c? -> *a?b*c? (? matches one character.)
"       dir/file -> dir/*f*i*l*e*
"       d*r/file -> d*r/*f*i*l*e*
"       ../**/s -> ../**/*s* (** allows searching a directory tree.)
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
"           :FuzzyFinderBuffer      - launchs the buffer-mode explorer.
"           :FuzzyFinderFile        - launchs the file-mode explorer.
"           :FuzzyFinderMru         - launchs the MRU-mode explorer.
"           :FuzzyFinderFavorite    - launchs the favorite-mode explorer.
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
"       vertically. These key mappings are customizable.
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
"           :FuzzyFinderAddFavorite {filename}
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
"   g:FuzzyFinder_MruModeVars:
"       This is a dictionary. This applies only to the MRU mode.
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
"           This is an upper limit of MRU items to be stored. If 0 was set, it
"           does not limit.
"
"   g:FuzzyFinder_FavoriteModeVars:
"       This is a dictionary. This applies only to the MRU mode.
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
"       :let g:FuzzyFinder_MruModeVars = { 'maxItems' : 99 }
"       :nnoremap <C-n> :FuzzyFinderBuffer<CR>
"       :nnoremap <C-p> :FuzzyFinderFile<CR>
"       :nnoremap <C-b> :FuzzyFinderMru<CR>
"       :nnoremap <C-f> :FuzzyFinderFavorite<CR>
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
    let s:version = '1.0'

    let s:path_separator = has('win32') ? '\' : '/'
    let s:prompt = '>'
    let s:aborted_result = [{'word': ' ', 'abbr': 'ABORT: Too many matches (> g:FuzzyFinder_FileModeVars.maxMatches)'}]
    let s:matching_rate_base = 10000000
    let s:sid_prefix = matchstr(expand('<sfile>'), '<SNR>\d\+_')

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
        let g:FuzzyFinder_Migemo = 1
    endif
    ".........................................................................
    if !exists('g:FuzzyFinder_BufferModeVars')
        let g:FuzzyFinder_BufferModeVars = {}
    endif
    call extend(g:FuzzyFinder_BufferModeVars,
                \ { 'name'                 : 'buffer',
                \   'command'              : [':buffer ', ':sbuffer ', ':vertical :sbuffer '],
                \   'bufferName'           : '[FuzzyFinder - Buffer]',
                \   'initialInput'         : '',
                \   'abbrevMap'            : {},
                \   'minLength'            : 0,
                \   'excludedIndicator'    : '[u\-]',
                \   'complete'             : function('<SID>CompleteBuffer')
                \ } ,'keep')
    ".........................................................................
    if !exists('g:FuzzyFinder_FileModeVars')
        let g:FuzzyFinder_FileModeVars = {}
    endif
    call extend(g:FuzzyFinder_FileModeVars,
                \ { 'name'                 : 'file',
                \   'command'              : [':edit ', ':split ', ':vsplit '],
                \   'bufferName'           : '[FuzzyFinder - File]',
                \   'initialInput'         : '',
                \   'abbrevMap'            : {},
                \   'minLength'            : 0,
                \   'excludedPath'         : '\v\~$|\.bak$|\.swp$|((^|[/\\])\.[/\\]$)',
                \   'maxMatches'           : 400,
                \   'complete'             : function('<SID>CompleteFile')
                \ } ,'keep')
    ".........................................................................
    if !exists('g:FuzzyFinder_MruModeVars')
        let g:FuzzyFinder_MruModeVars = {}
    endif
    call extend(g:FuzzyFinder_MruModeVars,
                \ { 'name'                 : 'mru',
                \   'command'              : [':edit ', ':split ', ':vsplit '],
                \   'bufferName'           : '[FuzzyFinder - MRU]',
                \   'initialInput'         : '',
                \   'abbrevMap'            : {},
                \   'minLength'            : 0,
                \   'ignoreSpecialBuffers' : 1,
                \   'excludedPath'         : '\v\~$|\.bak$|\.swp$',
                \   'maxItems'             : 20,
                \   'complete'             : function('<SID>CompleteMru')
                \ } ,'keep')
    ".........................................................................
    if !exists('g:FuzzyFinder_FavoriteModeVars')
        let g:FuzzyFinder_FavoriteModeVars = {}
    endif
    call extend(g:FuzzyFinder_FavoriteModeVars,
                \ { 'name'                 : 'favorite',
                \   'command'              : [':edit ', ':split ', ':vsplit '],
                \   'bufferName'           : '[FuzzyFinder - Favorite]',
                \   'initialInput'         : '',
                \   'abbrevMap'            : {},
                \   'minLength'            : 0,
                \   'complete'             : function('<SID>CompleteFavorite')
                \ } ,'keep')
    ".........................................................................

    "-------------------------------------------------------------------------
    " COMMANDS
    command! -bar -narg=0                FuzzyFinderBuffer      call <SID>OpenFuzzyFinder(g:FuzzyFinder_BufferModeVars.name)
    command! -bar -narg=0                FuzzyFinderFile        call <SID>OpenFuzzyFinder(g:FuzzyFinder_FileModeVars.name)
    command! -bar -narg=0                FuzzyFinderMru         call <SID>OpenFuzzyFinder(g:FuzzyFinder_MruModeVars.name)
    command! -bar -narg=0                FuzzyFinderFavorite    call <SID>OpenFuzzyFinder(g:FuzzyFinder_FavoriteModeVars.name)
    command! -bar -narg=1                FuzzyFinder            call <SID>OpenFuzzyFinder(<args>)
    command! -bar -narg=1                FuzzyFinderAddMode     call <SID>AddMode(<args>)
    command! -bar -narg=? -complete=file FuzzyFinderAddFavorite call <SID>UpdateFavoriteInfo(<q-args>, 1)

    "-------------------------------------------------------------------------
    " AUTOCOMMANDS
        augroup FuzzyFinder_GlobalAutoCommand
            autocmd!
            autocmd BufEnter     * call <SID>OnBufEnter()
            autocmd BufWritePost * call <SID>OnBufWritePost()
        augroup END


    "-------------------------------------------------------------------------
    " ETC
    let s:info = <SID>ReadInfoFile()
    call <SID>AddMode(g:FuzzyFinder_BufferModeVars  )
    call <SID>AddMode(g:FuzzyFinder_FileModeVars    )
    call <SID>AddMode(g:FuzzyFinder_MruModeVars     )
    call <SID>AddMode(g:FuzzyFinder_FavoriteModeVars)

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

        " global setting
        let s:_completeopt = &completeopt
        let &completeopt = 'menuone'
        let s:_ignorecase = &ignorecase
        let &ignorecase = g:FuzzyFinder_IgnoreCase

        " local setting
        setlocal bufhidden=wipe
        setlocal buftype=nofile
        setlocal noswapfile
        setlocal nobuflisted
        setlocal modifiable
        let &l:completefunc = s:sid_prefix . 'Complete'


        " autocommands
        augroup FuzzyFinder_LocalAutoCommand
            autocmd!
            autocmd CursorMovedI <buffer>        call feedkeys(<SID>OnCursorMovedI(), 'n')
            autocmd InsertLeave  <buffer> nested call feedkeys(<SID>OnInsertLeave() , 'n')
            autocmd BufLeave     <buffer>        call feedkeys(<SID>OnBufLeave()    , 'n')
        augroup END

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

    echo "Making buffer list..."
    redir => buffers | silent buffers! | redir END
    let matchlist_pattern = '^\s*\(\d*\)\s*\([^"]*\)\s*"\([^"]*\)".*$'
    let result = filter(map(split(buffers, "\n"),
                \           'matchlist(v:val, matchlist_pattern)'),
                \       'v:val[1] != s:buf_nr && v:val[2] !~ s:vars_current.excludedIndicator && ' .
                \       '(v:val[1] == patterns.base || v:val[3] =~ patterns.re)')

    echo 'Evaluating...'
    call map(result, '<SID>MakeCompletionItemWithRating(v:val[3], v:val[1], v:val[0], a:base)')

    echo 'pattern:' . patterns.wi

    return result
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
        call map(result, '<SID>MakeCompletionItemWithRating(v:val, -1, v:val, a:base)')
    endif

    echo 'pattern:' . patterns[0].base . patterns[1].wi

    return result
endfunction

"-----------------------------------------------------------------------------
function! <SID>CompleteMru(base)
    let patterns = <SID>MakeFuzzyPattern(a:base)

    if strlen(a:base) < s:vars_current.minLength || !has_key(s:info, g:FuzzyFinder_MruModeVars.name)
        return []
    endif

    let result = copy(s:info[g:FuzzyFinder_MruModeVars.name])
    let i = 0 | while i < len(result)
        let n = i + 1
        let result[i] = <SID>MakeCompletionItemWithRating(result[i], n, n . ": " . result[i], a:base)
        let result[i].order[1] = n
        let result[i].number = n
        let i += 1
    endwhile

    echo 'pattern:' . patterns.wi

    return filter(result, 'v:val.number == patterns.base || v:val.word =~ patterns.re')

endfunction

"-----------------------------------------------------------------------------
function! <SID>CompleteFavorite(base)
    let patterns = <SID>MakeFuzzyPattern(a:base)

    if strlen(a:base) < s:vars_current.minLength || !has_key(s:info, g:FuzzyFinder_FavoriteModeVars.name)
        return []
    endif

    let result = copy(s:info[g:FuzzyFinder_FavoriteModeVars.name])
    let i = 0 | while i < len(result)
        let n = i + 1
        let result[i] = <SID>MakeCompletionItemWithRating(result[i], n, n . ": " . result[i], a:base)
        let result[i].order[1] = n
        let result[i].number = n
        let i += 1
    endwhile

    echo 'pattern:' . patterns.wi

    return filter(result, 'v:val.number == patterns.base || v:val.word =~ patterns.re')

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

    if g:FuzzyFinder_Migemo && has('migemo') && a:base !~ '[^\x01-\x7e]'
        let re .= '\|\m.*' . substitute(migemo(a:base), '\\_s\*', '.*', 'g') . '.*'
    endif

    return { 'base': a:base, 'wi':wi, 're': re }
endfunction

"-----------------------------------------------------------------------------
function! <SID>ExpandAbbrevMap(base, abbrev_map)
    let result = [a:base]

    " expand
    for [pattern, sub_list] in items(a:abbrev_map)
        "if type(sub_list) == type("")
        "    let sub_list = [sub_list]
        "endif
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
function! <SID>MakeCompletionItemWithRating(path, buf_nr, abbr, input)
    let rate = <SID>EvaluateMatchingRate(a:path, a:buf_nr, a:input)
    let rate_based_5 = (5 * rate) / s:matching_rate_base

    return      { 'word'  : a:path,
                \ 'abbr'  : a:abbr,
                \ 'menu'  : '|' . repeat('*', rate_based_5) . repeat('.', 5 - rate_based_5),
                \ 'order' : [-rate, a:path]}
endfunction

"-----------------------------------------------------------------------------
function! <SID>EvaluateMatchingRate(path, buf_nr, input)
    let path_tail  = <SID>SplitPath(matchstr(a:path , '^.*[^/\\]'))[1]
    let input_tail = <SID>SplitPath(a:input)[1]

    if (a:buf_nr >= 0 && str2nr(a:buf_nr) == str2nr(a:input)) || a:path == a:input || path_tail == input_tail
        return s:matching_rate_base
    endif

    let rate = 0.0
    let rate_increment = (s:matching_rate_base * 9) / (len(input_tail) * 10) " zero divide ok
    let matched = 1
    let i0 = 0 | let i1 = 0 | while i0 < len(path_tail) && i1 < len(input_tail)
        if path_tail[i0] == input_tail[i1]
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
    let info = {}
    try
        let lines = filter(map(readfile(expand(g:FuzzyFinder_InfoFile)),
                    \          'matchlist(v:val, "^\\([^\\t]\\+\\)\\t\\(.*\\)$")'),
                    \      '!empty(v:val)')
    catch /.*/ 
        return info
    endtry

    for line in lines
        if !has_key(info, line[1])
            let info[line[1]] = []
        endif
        call add(info[line[1]], line[2])
    endfor
    if has_key(info, 'version') && info.version[0] != s:version
        let info = {}
    endif

    return info
endfunction

"-----------------------------------------------------------------------------
function! <SID>WriteInfoFile(info)
    let a:info.version = [s:version]
    let lines = []
    for [key, value] in items(a:info)
        let lines += map(copy(value), 'key . "\t" . v:val')
    endfor

    try
        call writefile(lines, expand(g:FuzzyFinder_InfoFile))
    catch /.*/ 
    endtry

endfunction

"-----------------------------------------------------------------------------
function! <SID>UpdateMruInfo(file)
    let s:info = <SID>ReadInfoFile()

    if !has_key(s:info, 'mru')
        let s:info.mru = []
    endif

    let s:info.mru = filter(insert(filter(s:info.mru,'v:val != a:file'), a:file),
                \           'v:val !~ g:FuzzyFinder_MruModeVars.excludedPath && filereadable(v:val)'
                \          )[0 : g:FuzzyFinder_MruModeVars.maxItems - 1]

    call <SID>WriteInfoFile(s:info)
endfunction

"-----------------------------------------------------------------------------
function! <SID>UpdateFavoriteInfo(in_file, adds)
    if empty(a:in_file)
        let file = expand('%:p')
    else
        let file = fnamemodify(a:in_file, ':p')
    endif

    let s:info = <SID>ReadInfoFile()

    if !has_key(s:info, 'favorite')
        let s:info.favorite = []
    endif

    let s:info.favorite = filter(s:info.favorite,'v:val != file')

    if a:adds
        let s:info.favorite = add(s:info.favorite, file)
    endif

    call <SID>WriteInfoFile(s:info)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EVENT HANDLER:
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"-----------------------------------------------------------------------------
function! <SID>OnBufEnter()
    if !g:FuzzyFinder_MruModeVars.ignoreSpecialBuffers || empty(&buftype)
        call <SID>UpdateMruInfo(expand('%:p')) " == '<afile>:p'
    endif
    return ""
endfunction

"-----------------------------------------------------------------------------
function! <SID>OnBufWritePost()
    if !g:FuzzyFinder_MruModeVars.ignoreSpecialBuffers || empty(&buftype)
        call <SID>UpdateMruInfo(expand('%:p')) " == '<afile>:p'
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
        let command = s:reserved_command
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
        let s:reserved_command = s:vars_current.command[a:index] . getline('.')[strlen(s:prompt):] . "\<CR>"
    else
        let s:reserved_command = s:vars_current.command[a:index] . getline('.') . "\<CR>"
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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INITIALIZE:
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call <SID>Initialize()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

