""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" fuzzyfinder.vim : Buffer and file explorer with the fuzzy pattern
" Last Change:  12-Sep-2007.
" Author:       Takeshi Nishida <ns9tks(at)ns9tks.net>
" Version:      0.5, for Vim 7.0
" Licence:      MIT Licence
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Description:
"     With fuzzyfinder, you can quickly reach the buffer or file you want with
"     less typing. Fuzzyfinder find matching files or buffers with the fuzzy
"     pattern to which fuzzyfinder converted the inputting pattern.
"
"     E.g.: the inputting pattern / the fuzzy pattern
"         abc -> *a*b*c*
"         a*b*c* -> *a*b*c*
"         a?b*c? -> *a?b*c? (? matches one character.)
"         dir/file -> dir/*f*i*l*e*
"         d*r/file -> d*r/*f*i*l*e*
"         ../**/s -> ../**/*s* (** allows searching a directory tree.)
"
"     You will be happy when:
"         "./OhLongLongLongLongLongFile.txt"
"         "./AhLongLongLongLongLongName.txt"
"         "./AhLongLongLongLongLongFile.txt" <- you want :O
"         Type "AF" and "AhLongLongLongLongLongFile.txt" will be select. :D
"
"     Fuzzyfinder supports multibyte.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Installation:
"     Drop this file in your plugin directory.  If you have installed
"     autocomplpop.vim (vimscript #1879), please update to the latest version
"     to prevent interference.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Usage:
"     :FuzzyFinderBuffer opens a small window for a buffer explorer.
"     :FuzzyFinderFile opens a small window for a file explorer.
"
"     It is recommended to map these. Personally, I map these to <C-n> and
"     <C-p>.
"
"     To switch between a buffer mode and a file mode without leaving a insert
"     mode, use <F12> by default.
"
"     If you want to temporarily change whether or not to ignore case, use
"     <F11> by default.
"
"     The inputting pattern you typed is converted to the fuzzy pattern
"     and buffers/files which match the pattern is shown in a completion
"     menu.
"
"     A completion menu is shown when you type at the end of the line and the
"     length of inputting pattern is more than setting value. By default, all
"     buffers or all files in current directory is shown at the beginning.
"
"     If too many items (400, by default) were matched, the completion is
"     aborted to reduce nonresponse.
"
"     If inputting pattern matched the item perfectly, the item is shown first
"     and selected in completion menu. Same applies to the buffer number in a
"     buffer mode. The item which has longer prefix matching is placed upper.
"
"     Pressing <CR> opens selected item in previous window. If selected item
"     was directory in a file mode, it just inserts text. Use <F9> to open
"     in new window which is made from split previous window, or <F10> To open
"     in new window which is made from split previous window vertically. These
"     key mappings are customizable.
"
"     To cancel and return to previous window, leave a insert mode.
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Options:
"     See a section setting global value below.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Thanks:
"     Vincent Wang
"     Ingo Karkat
"     Nikolay Golubev
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ChangeLog:
"     0.5:
"         - Improved response by aborting processing too many items.
"         - Changed to be able to open a buffer/file not only in previous
"           window but also in new window.
"         - Fixed a bug that recursive searching with '**' does not work.
"         - Added g:FuzzyFinder_CompletionItemLimit option.
"         - Added g:FuzzyFinder_KeyOpen option.
"
"     0.4:
"         - Improved response of the input.
"         - Improved the sorting algorithm for completion items. It is based
"           on the matching level. 1st is perfect matching, 2nd is prefix
"           matching, and 3rd is fuzzy matching.
"         - Added g:FuzzyFinder_ExcludePattern option.
"         - Removed g:FuzzyFinder_WildIgnore option.
"         - Removed g:FuzzyFinder_EchoPattern option.
"         - Removed g:FuzzyFinder_PathSeparator option.
"         - Changed the default value of g:FuzzyFinder_MinLengthFile from 1 to
"           0.
"
"     0.3:
"         - Added g:FuzzyFinder_IgnoreCase option.
"         - Added g:FuzzyFinder_KeyToggleIgnoreCase option.
"         - Added g:FuzzyFinder_EchoPattern option.
"         - Changed the open command in a buffer mode from ":edit" to
"           ":buffer" to avoid being reset cursor position.
"         - Changed the default value of g:FuzzyFinder_KeyToggleMode from
"           <C-Space> to <F12> because <C-Space> does not work on some CUI
"           environments.
"         - Changed to avoid being loaded by Vim before 7.0.
"         - Fixed a bug with making a fuzzy pattern which has '\'.
"
"     0.2:
"         - A bug it does not work on Linux is fixed.
"
"     0.1:
"         - First release.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists('loaded_fuzzyfinder') || v:version < 700
    finish
endif
let loaded_fuzzyfinder = 1


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Map this to select completion item or to finish input and open a
" buffer/file. 1st item is mapped to open in previous window. 2nd item is
" mapped to open in new window which is made from split previous window. 3rd
" item is mapped to open in new window which is made from split previous
" window vertically.
if !exists('g:FuzzyFinder_KeyOpen')
    let g:FuzzyFinder_KeyOpen = ['<CR>', '<F9>', '<F10>']
endif

" Map this to toggle buffer mode and file mode in insert mode.
if !exists('g:FuzzyFinder_KeyToggleMode')
    let g:FuzzyFinder_KeyToggleMode = '<F12>'
endif

" Map this to temporarily toggle whether or not to ignore case.
if !exists('g:FuzzyFinder_KeyToggleIgnoreCase')
    let g:FuzzyFinder_KeyToggleIgnoreCase = '<F11>'
endif

" If items were matched over this, processing completion is aborted. 
if !exists('g:FuzzyFinder_CompletionItemLimit')
    let g:FuzzyFinder_CompletionItemLimit = 400
endif

" In buffer mode, do not complete if a length of inputting is less than this.
if !exists('g:FuzzyFinder_MinLengthBuffer')
    let g:FuzzyFinder_MinLengthBuffer = 0
endif

" In file mode, do not complete if a length of inputting is less than this.
if !exists('g:FuzzyFinder_MinLengthFile')
    let g:FuzzyFinder_MinLengthFile = 0
endif

" In buffer/file mode, ignore case in search patterns.
if !exists('g:FuzzyFinder_IgnoreCase')
    let g:FuzzyFinder_IgnoreCase = &ignorecase
endif

" In file mode, files which matches this are ignored.
if !exists('g:FuzzyFinder_ExcludePattern')
    let g:FuzzyFinder_ExcludePattern = '^\.$\|\.bak$\|\~$\|\.swp$'
endif

" In buffer mode, buffers with an indicator matching this are ignored.
if !exists('g:FuzzyFinder_ExcludeIndicator')
    let g:FuzzyFinder_ExcludeIndicator = '[u\-]'
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! -narg=0 -bar FuzzyFinderBuffer call <SID>StartBufferMode()
command! -narg=0 -bar FuzzyFinderFile   call <SID>StartFileMode()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" constants

let s:pathSeparator = has('win32') ? '\' : '/'
let s:prompt = '>'
let s:abortedResult = [{'word': ' ', 'abbr': 'ABORT: Too many matches (> g:FuzzyFinder_CompletionItemLimit)'}]


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>OnCR(in)
    return (pumvisible() ? "\<C-Y>" : "") . "\<C-R>=" . <SID>GetSIDPrefix() . "OpenItem('" . a:in . "'," . pumvisible() . ")\<CR>"
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>OnBS()
    return pumvisible() ? "\<C-E>\<BS>" : "\<BS>"
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>OnCursorMovedI()
    if !<SID>ExistsPrompt(getline('.'))
        " a command prompt is removed
        call setline('.', s:prompt . getline('.'))
        call feedkeys(repeat("\<Right>", len(s:prompt)), 'n')
        return
    elseif col('.') <= len(s:prompt)
        call feedkeys(repeat("\<Right>", len(s:prompt) - col('.') + 1), 'n')
        return
    endif

    let deltaInputLength  = strlen(getline('.')) - s:lastInputLength
    let s:lastInputLength = strlen(getline('.'))

    " if the line was changed and cursor is placed on the end of the line
    if deltaInputLength != 0 && col('.') > s:lastInputLength
        call feedkeys("\<C-X>\<C-U>", 'n')
    endif
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>OnInsertLeave()
    if exists('s:reserveToggleMode')
        unlet s:reserveToggleMode
        call <SID>OpenInputWindow(!s:isLastModeBuffer)
    else
        quit
    endif
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>OnBufLeave()
    " resume autocomplpop.vim
    if exists(':AutoComplPopUnlock')
        :AutoComplPopUnlock
    endif

    call <SID>ClearGlobExCache()

    let &completeopt = s:_completeopt
    let &ignorecase  = s:_ignorecase
    unlet s:bufNr

    quit " Quit when other window clicked without leaving a insert mode.
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>StartBufferMode()
    call <SID>OpenInputWindow(1)
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>StartFileMode()
    call <SID>OpenInputWindow(0)
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>ToggleMode()
    let s:reserveToggleMode = 1
    return "\<ESC>"
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>ToggleIgnoreCase()
    let &ignorecase = !&ignorecase
    echo "ignorecase=" . &ignorecase
    return ""
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>OpenInputWindow(isBufferMode)

    " differences between modes
    if a:isBufferMode
        let cmdOpen  = [':buffer ', ':sbuffer ', ':vertical :sbuffer ']
        let bufferName = '[FuzzyFinder - Buffer]'
        let completeFunc = <SID>GetSIDPrefix() . 'CompleteBuffer'
    else
        let cmdOpen  = [':edit ', ':split ', ':vsplit ']
        let bufferName = '[FuzzyFinder - File]'
        let completeFunc = <SID>GetSIDPrefix() . 'CompleteFile'
    endif

    let s:isLastModeBuffer = a:isBufferMode
    let s:lastInputLength = -1

    if exists('s:bufNr')
        " a buffer for fuzzyfinder already created
        execute 'buffer ' . s:bufNr
        delete _
    else
        1new
        let s:bufNr = bufnr('%')

        " suspend autocomplpop.vim
        if exists(':AutoComplPopLock')
            :AutoComplPopLock
        endif

        " global setting
        let s:_completeopt = &completeopt
        set completeopt=menuone
        let s:_ignorecase = &ignorecase
        let &ignorecase = g:FuzzyFinder_IgnoreCase

        " local setting
        setlocal bufhidden=wipe
        setlocal buftype=nofile
        setlocal noswapfile
        setlocal nobuflisted
        setlocal modifiable

        " mapping
        execute "inoremap <buffer> <silent> <expr> " . g:FuzzyFinder_KeyToggleMode       . " <SID>ToggleMode()"
        execute "inoremap <buffer> <silent> <expr> " . g:FuzzyFinder_KeyToggleIgnoreCase . " <SID>ToggleIgnoreCase()"
        execute "inoremap <buffer> <silent> <expr> " . g:FuzzyFinder_KeyOpen[0]          . " <SID>OnCR('" . cmdOpen[0] . "')"
        execute "inoremap <buffer> <silent> <expr> " . g:FuzzyFinder_KeyOpen[1]          . " <SID>OnCR('" . cmdOpen[1] . "')"
        execute "inoremap <buffer> <silent> <expr> " . g:FuzzyFinder_KeyOpen[2]          . " <SID>OnCR('" . cmdOpen[2] . "')"
        execute "inoremap <buffer> <silent> <expr> " . "<BS>"                            . " <SID>OnBS()"

        " auto command
        augroup FuzzyFinder_AutoCommand
            autocmd!
            autocmd InsertLeave  <buffer> nested call <SID>OnInsertLeave()
            autocmd CursorMovedI <buffer>        call <SID>OnCursorMovedI()
            autocmd BufLeave     <buffer>        call <SID>OnBufLeave()
        augroup END

    endif

    let &l:completefunc = completeFunc

    execute 'file ' . bufferName

    " start insert mode. s:prompt makes CursorMovedI event now
    " and forces a completion menu to update every typing.
    call feedkeys('i' . s:prompt, 'n')

endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>OpenItem(cmdOpen, checkDir)
    if a:checkDir && getline('.') =~ '[/\\]$'
        return ""
    endif

    return "\<Esc>" . a:cmdOpen . (<SID>ExistsPrompt(getline('.')) ? getline('.')[strlen(s:prompt):] : getline('.')) . "\<CR>"
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>CompleteBuffer(findstart, base)
    if a:findstart
        return 0
    endif

    let input    = a:base[strlen(s:prompt):]
    let patternW = <SID>MakeFuzzyPattern(input)
    let patternR = <SID>ConvertWildcardToRegexp(patternW)

    if !<SID>ExistsPrompt(a:base) || strlen(input) < g:FuzzyFinder_MinLengthBuffer
        echo ""
        return []
    endif

    echo "Making buffer list..."
    redir => l:lines | silent buffers! | redir END
    let matchlistPattern = '^\s*\(\d*\)\s*\([^"]*\)\s*"\([^"]*\)".*$'
    let result = map(split(lines, "\n"), 'matchlist(v:val, matchlistPattern)')
    call filter(result, 'v:val[1] != s:bufNr && v:val[2] !~ g:FuzzyFinder_ExcludeIndicator && (v:val[1] == input || v:val[3] =~ patternR)')

    echo 'Evaluating...'
    if g:FuzzyFinder_CompletionItemLimit > 0 && len(result) > g:FuzzyFinder_CompletionItemLimit
        let result = s:abortedResult
        call feedkeys("\<C-P>")
    elseif !empty(result)
        call map (result, '<SID>MakeCompletionItemWithMatchingLevel(v:val[3], v:val[1], v:val[0], input)')
        call sort(result, '<SID>SortByMatchingLevel')

        if !empty(result)
            call feedkeys("\<C-P>\<Down>")
        endif
    endif

    echo 'pattern:' . patternW

    return result
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>CompleteFile(findstart, base)
    if a:findstart
        return 0
    endif

    let input     = a:base[strlen(s:prompt):]
    let inputPair = <SID>SplitPath(input)
    let patternW  = inputPair[0] . <SID>MakeFuzzyPattern(inputPair[1])

    if !<SID>ExistsPrompt(a:base) || strlen(inputPair[1]) < g:FuzzyFinder_MinLengthFile
        echo ""
        return []
    endif

    echo 'Making file list...'
    let result = <SID>GlobEx(patternW)

    echo 'Evaluating...'
    if g:FuzzyFinder_CompletionItemLimit > 0 && len(result) > g:FuzzyFinder_CompletionItemLimit
        let result = s:abortedResult
        call feedkeys("\<C-P>")
    elseif !empty(result)
        call map (result, '<SID>MakeCompletionItemWithMatchingLevel(v:val, -1, v:val, input)')
        call sort(result, '<SID>SortByMatchingLevel')

        if !empty(result)
            call feedkeys("\<C-P>\<Down>")
        endif
    endif

    echo 'pattern:' . patternW

    return result
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" "str" -> "*s*t*r*" 
function! <SID>MakeFuzzyPattern(in)
    let out = ''

    for char in split(a:in,'\zs')
        if out !~ '[*?]$' && char !~ '[*?]'
            let out .= '*'. char
        else
            let out .= char
        endif
    endfor

    if out !~ '[*?]$'
        return out . '*'
    endif

    return out
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>ConvertWildcardToRegexp(in)
    let out = escape(a:in, '\')
    let out = substitute(out, '*', '\\.\\*', 'g')
    let out = substitute(out, '?', '\\.'   , 'g')
    let out = substitute(out, '[', '\\['   , 'g')
    let out = '\V' . out
    return out
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>ExpandCase(in)
    let out = ''
    for char in split(a:in,'\zs')
        if char =~ '\a'
            let out .= '[' . toupper(char) . tolower(char) . ']'
        else
            let out .= char
        endif
    endfor

    return out
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>ExistsPrompt(in)
    return strlen(a:in) >= strlen(s:prompt) && a:in[:strlen(s:prompt) -1] ==# s:prompt
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>SplitPath(path)
    let dir = matchstr(a:path, '^.*[/\\]')
    return [dir, a:path[strlen(dir):]]
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


function! <SID>GlobEx(patternW)
    let patternWHead = <SID>SplitPath(a:patternW)[0]

    if !exists('s:globExCacheDir') || s:globExCacheDir != patternWHead
        let s:globExCacheDir = patternWHead

        let dirList = patternWHead =~ '\S' ? split(expand(patternWHead), "\n") : [""]

        let s:globExCache = []
        for dir in dirList
            let s:globExCache += split(glob(dir . '.*') . "\n" . glob(dir . '*' ), "\n")
        endfor

        call filter(s:globExCache, '<SID>SplitPath(v:val)[1] !~ g:FuzzyFinder_ExcludePattern')
        if len(dirList) <= 1
            call map(s:globExCache, '[patternWHead, <SID>SplitPath(v:val)[1], (isdirectory(v:val) ? s:pathSeparator : "")]')
        else 
            call map(s:globExCache, '<SID>SplitPath(v:val) + [(isdirectory(v:val) ? s:pathSeparator : "")]')
        endif
    endif

    let patternRTail = <SID>ConvertWildcardToRegexp(<SID>SplitPath(a:patternW)[1])
    return map(filter(copy(s:globExCache), 'v:val[1] =~ patternRTail'), 'v:val[0] . v:val[1] . v:val[2]')
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>ClearGlobExCache()
    unlet! s:globExCacheDir
    unlet! s:globExCache
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>ShellEscapeEx(path)
    return a:path =~ '\s' ? shellescape(a:path) : a:path
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>MakeCompletionItemWithMatchingLevel(path, bufNr, abbr, input)
    let pathTail  = <SID>SplitPath(matchstr(a:path , '^.*[^/\\]'))[1]
    let inputTail = <SID>SplitPath(matchstr(a:input, '^.*[^/\\]'))[1]

    " Evaluates matching level
    if a:bufNr >= 0 && a:bufNr == a:input
        let mlevel = strlen(inputTail) + 3
    elseif a:path == a:input
        let mlevel = strlen(inputTail) + 2
    elseif pathTail == inputTail
        let mlevel = strlen(inputTail) + 1
    else
        let mlevel = 0
        while mlevel < strlen(inputTail) && pathTail[mlevel] == inputTail[mlevel]
            let mlevel += 1
        endwhile
    endif

    return      { 'word'  : a:path,
                \ 'abbr'  : a:abbr,
                \ 'menu'  : '| ' . repeat('*', mlevel),
                \ 'mlevel': mlevel}
endfunction



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>SortByMatchingLevel(i1, i2)
    if     a:i1['mlevel'] < a:i2['mlevel']
        return +1
    elseif a:i1['mlevel'] > a:i2['mlevel']
        return -1
    elseif a:i1['word'] > a:i2['word']
        return +1
    elseif a:i1['word'] < a:i2['word']
        return -1
    endif
    return 0
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>GetSIDPrefix()
    return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

