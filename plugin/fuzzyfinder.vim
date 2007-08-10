""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" fuzzyfinder.vim : Buffer and file explorer with the fuzzy pattern
" Last Change:  11-Aug-2007.
" Author:       Takeshi Nishida <ns9tks(at)ns9tks.net>
" Version:      0.3, for Vim 7.0
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
"     and buffers or files which match the pattern is shown in a completion
"     menu.
"
"     A completion menu is shown when you type at the end of the line and the
"     length of inputting pattern is more than setting value. At the start of
"     a buffer mode, all buffers list is shown by default. In a file mode, a
"     completion menu is not shown while the length of inputting filename is
"     less than 1 by default.
"
"     If inputting pattern matches the item perfectly, the item is shown first
"     and selected in completion menu. Same applies to the buffer number in a
"     buffer mode.
"
"     Pressing <CR> opens selected item in the previous window. If selected
"     item is directory in a file mode, it inserts but does not open.
"
"     To cancel and return the previous window, leave a insert mode.
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
"     0.3:
"         - Added g:FuzzyFinder_IgnoreCase option.
"         - Added g:FuzzyFinder_KeyToggleIgnoreCase option.
"         - Added g:FuzzyFinder_EchoPattern option.
"         - Changed the open command in a buffer mode from ":edit" to
"         ":buffer" to avoid being reset cursor position.
"         - Changed the default value of g:FuzzyFinder_KeyToggleMode from
"         <C-Space> to <F12> because <C-Space> does not work on some CUI
"         environments.
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

if exists("loaded_fuzzyfinder") || v:version < 700
    finish
endif
let loaded_fuzzyfinder = 1


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Map this to toggle buffer mode and file mode in insert mode.
if !exists('g:FuzzyFinder_KeyToggleMode')
    let g:FuzzyFinder_KeyToggleMode = '<F12>'
endif

" Map this to temporarily toggle whether or not to ignore case.
if !exists('g:FuzzyFinder_KeyToggleIgnoreCase')
    let g:FuzzyFinder_KeyToggleIgnoreCase = '<F11>'
endif

" Path separator.
if !exists('g:FuzzyFinder_PathSeparator')
    let g:FuzzyFinder_PathSeparator = (has('win32') ? '\' : '/')
endif

" In buffer mode, do not complete if a length of inputting is less than this.
if !exists('g:FuzzyFinder_MinLengthBuffer')
    let g:FuzzyFinder_MinLengthBuffer = 0
endif

" In file mode, do not complete if a length of inputting is less than this.
if !exists('g:FuzzyFinder_MinLengthFile')
    let g:FuzzyFinder_MinLengthFile = 1
endif

" In buffer and file mode, ignore case in search patterns.
if !exists('g:FuzzyFinder_IgnoreCase')
    let g:FuzzyFinder_IgnoreCase = &ignorecase
endif

" In file mode, set this to 'wildignore'
if !exists('g:FuzzyFinder_WildIgnore')
    let g:FuzzyFinder_WildIgnore = '*~,*.bak'
endif

" In buffer mode, buffers with an indicator matching this are ignored
if !exists('g:FuzzyFinder_ExcludeIndicator')
    let g:FuzzyFinder_ExcludeIndicator = '[u\-]'
endif

" Echo the fuzzy pattern which is converted from the pattern what you are
" typing.
if !exists('g:FuzzyFinder_EchoPattern')
    let g:FuzzyFinder_EchoPattern = 0
endif



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! -narg=0 -bar FuzzyFinderBuffer call <SID>StartBufferMode()
command! -narg=0 -bar FuzzyFinderFile   call <SID>StartFileMode()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:cmdPrompt = '>'
let s:bufID = -1
let s:isLastModeBuffer = 0
let s:openCommand = 0
let s:reserveToggleMode = 0


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
        let s:openCommand = ':buffer '
        let bufferName = '[FuzzyFinder - Buffer]'
        let completeFunc = 'FuzzyFinder_CompleteBuffer'
    else
        let s:openCommand = ':edit '
        let bufferName = '[FuzzyFinder - File]'
        let completeFunc = 'FuzzyFinder_CompleteFile'
    endif

    let s:isLastModeBuffer = a:isBufferMode
    let s:lastInputLength = -1

    if s:bufID != -1
        " a buffer already created
        execute 'buffer ' . s:bufID
        delete _
    else
        1new
        let s:bufID = bufnr('%')

        " suspend autocomplpop.vim
        if exists(':AutoComplPopLock')
            :AutoComplPopLock
        endif

        " global setting
        let s:_completeopt = &completeopt
        set completeopt=menuone
        let s:_ignorecase = &ignorecase
        let &ignorecase = g:FuzzyFinder_IgnoreCase
        let s:_wildignore = &wildignore
        let &wildignore = g:FuzzyFinder_WildIgnore

        " local setting
        setlocal bufhidden=wipe
        setlocal buftype=nofile
        setlocal noswapfile
        setlocal nobuflisted
        setlocal modifiable

        " mapping
        inoremap <buffer> <silent> <expr> <CR> <SID>OnCR()
        inoremap <buffer> <silent> <expr> <BS> pumvisible() ? "\<C-E>\<BS>" : "\<BS>"
        execute "inoremap <buffer> <silent> <expr> " . g:FuzzyFinder_KeyToggleMode .
                    \ " <SID>ToggleMode()"
        execute "inoremap <buffer> <silent> <expr> " . g:FuzzyFinder_KeyToggleIgnoreCase .
                    \ " <SID>ToggleIgnoreCase()"

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

    " start insert mode. s:cmdPrompt makes CursorMovedI event now
    " and forces a completion menu to update every typing.
    call feedkeys('i' . s:cmdPrompt, 'n')

endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! FuzzyFinder_CompleteBuffer(findstart, base)
    if a:findstart
        return 0
    endif

    let input = <SID>ExtractPromptedInput(a:base)

    if !input[0] || strlen(input[1]) < g:FuzzyFinder_MinLengthBuffer
        echo ""
        return []
    endif

    let patternW = <SID>MakeFuzzyPattern(input[1])
    let patternR = <SID>ConvertWildcardToRegexp(patternW)

    " make a list of buffers
    redir => l:lines
    silent buffers!
    redir END

    let res = []
    for line in split(lines, "\n")
        " bufInfo[1]: number,   bufInfo[2]: indicator,   bufInfo[3]: filename
        let bufInfo = matchlist(line, '^\s*\(\d*\)\s*\([^"]*\)\s*"\([^"]*\)"')
        let bufAbbr = (bufInfo[2] =~ 'a' ? '*' : ' ')

        if bufInfo[1] == s:bufID || bufInfo[2] =~ g:FuzzyFinder_ExcludeIndicator
            continue
        elseif bufInfo[1] == input[1] || bufInfo[3] == input[1]
            call insert(res, {'word': bufInfo[3], 'abbr': bufAbbr, 'menu': line})
        elseif bufInfo[3] =~ patternR
            call    add(res, {'word': bufInfo[3], 'abbr': bufAbbr, 'menu': line})
        endif
    endfor

    if g:FuzzyFinder_EchoPattern
        echo "pattern:" . patternW
    endif

    call feedkeys(!empty(res) ? "\<C-P>\<Down>" : "\<C-E>", 'n')

    return res
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! FuzzyFinder_CompleteFile(findstart, base)
    if a:findstart 
        return 0
    endif

    let input = <SID>ExtractPromptedInput(a:base)
    let pathHead = matchstr(input[1], '^.*[/\\]')
    let pathTail = input[1][strlen(pathHead):]

    if !input[0] || strlen(pathTail) < g:FuzzyFinder_MinLengthFile
        echo ""
        return []
    endif

    let patternW = pathHead . <SID>MakeFuzzyPattern(pathTail)
    let patternR = <SID>ConvertWildcardToRegexp(patternW)
    if &ignorecase  && !has('win32')
        let patternW = <SID>ExpandCase(patternW)
    endif


    let res = []
    for path in split(glob(patternW), "\n")
        if isdirectory(path)
            let path = path . g:FuzzyFinder_PathSeparator
        endif
        if path == input[1]
            call insert(res, {'word': path, 'menu': '| ' . fnamemodify(path, ':p')})
        elseif &ignorecase || path =~ patternR
            call    add(res, {'word': path, 'menu': '| ' . fnamemodify(path, ':p')})
        endif
    endfor

    if g:FuzzyFinder_EchoPattern
        echo "pattern:" . patternW
    endif

    call feedkeys(!empty(res) ? "\<C-P>\<Down>" : "\<C-E>", 'n')

    return res
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>OnCR()
    return pumvisible() ? "\<C-Y>\<C-R>=col('.') > strlen(getline('.')) && getline('.') !~ '[\\\\/]$' ? \"\\<CR>\" : \"\"\<CR>" : "\<CR>"
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>OnCursorMovedI()
    let input = <SID>ExtractPromptedInput(getline('1'))
    if line('.') != 1
        " Fix
        call feedkeys("\<Esc>" . s:openCommand . input[1] . "\<CR>", 'n')
        "call feedkeys("\<Esc>:e " . input[1] . "\<CR>", 'n')
        return
    elseif !input[0]
        " a command prompt is removed
        call feedkeys("\<Home>" . s:cmdPrompt . "\<End>", 'n')
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
    if s:reserveToggleMode
        let s:reserveToggleMode = 0
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

    let &completeopt = s:_completeopt
    let &ignorecase  = s:_ignorecase
    let &wildignore  = s:_wildignore
    let s:bufID = -1

    quit " Quit when other window clicked without leaving a insert mode.
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

function! <SID>ExtractPromptedInput(in)
    if strlen(a:in) < strlen(s:cmdPrompt) ||
                \ a:in[:strlen(s:cmdPrompt) -1] !=# s:cmdPrompt
        return [0, a:in]
    endif

    return [1, a:in[strlen(s:cmdPrompt):]]
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
