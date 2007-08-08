""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" fuzzyfinder.vim : Buffer and file explorer with the fuzzy pattern
" Last Change:  08-Aug-2007.
" Author:       Takeshi Nishida <ns9tks(at)ns9tks.net>
" Version:      0.1, for Vim 7.0
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
"     autocomplpop.vim(), please update to the latest version to prevent
"     interference.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Usage:
"     :FuzzyFinderBuffer opens a small window for a buffer explorer.
"     :FuzzyFinderFile opens a small window for a file explorer.
"
"     It is recommended to map these. Personally, I map these to <C-Space> and
"     <S-C-Space>.
"
"     To switch between a buffer mode and a file mode without leaving a insert
"     mode, use <C-Space> by default.
"
"     The inputting pattern you typed is converted to the fuzzy pattern
"     and buffers or files which match the pattern is shown in a completion
"     menu. The fuzzy pattern is echoed.
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
" ChangeLog:
"     0.1:
"         First release.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("loaded_fuzzyfinder")
    finish
endif
let loaded_fuzzyfinder = 1


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Map this to toggle buffer mode and file mode in insert mode.
if !exists('g:FuzzyFinder_KeyToggleMode')
    let g:FuzzyFinder_KeyToggleMode = '<C-Space>'
endif

" Path separator
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

" In file mode, set this to 'wildignore'
if !exists('g:FuzzyFinder_WildIgnore')
    let g:FuzzyFinder_WildIgnore = '*~,*.bak'
endif

" In buffer mode, buffers with an indicator matching this are ignored
if !exists('g:FuzzyFinder_ExcludeIndicator')
    let g:FuzzyFinder_ExcludeIndicator = '[u\-]'
endif



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! -narg=0 -bar FuzzyFinderBuffer call <SID>StartBufferMode()
command! -narg=0 -bar FuzzyFinderFile   call <SID>StartFileMode()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:bufID = -1
let s:isLastModeBuffer = 0
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

function! <SID>OpenInputWindow(isBufferMode)

    if a:isBufferMode
        let bufferName = '[FuzzyFinder - Buffer]'
        let completeFunc = 'FuzzyFinder_CompleteBuffer'
    else
        let bufferName = '[FuzzyFinder - File]'
        let completeFunc = 'FuzzyFinder_CompleteFile'
    endif

    let s:lastInputLength = -1
    let s:isLastModeBuffer = a:isBufferMode

    if s:bufID != -1
        " a buffer already created
        execute('buffer ' . s:bufID)
        delete _
    else
        1new
        let s:bufID = bufnr('%')

        " suspend autocomplpop.vim
        if exists(':AutoComplPopLock') | :AutoComplPopLock | endif

        " global setting
        let s:_completeopt = &completeopt
        set completeopt=menuone
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
        execute("inoremap <buffer> <silent> <expr> " . g:FuzzyFinder_KeyToggleMode . " <SID>ToggleMode()")

        " auto command
        augroup FuzzyFinder_AutoCommand
            autocmd!
            autocmd InsertLeave  <buffer> nested call <SID>OnInsertLeave()
            autocmd CursorMovedI <buffer>        call <SID>OnCursorMovedI()
            autocmd BufLeave     <buffer>        call <SID>OnBufLeave()
        augroup END

    endif

    let &l:completefunc = completeFunc

    execute('file ' . bufferName)

    " start insert mode. ">" makes CursorMovedI event now and forces a
    " completion menu to update every typing.
    call feedkeys("i>", 'n')
    "call feedkeys("i \<C-H>", 'n')

endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! FuzzyFinder_CompleteBuffer(findstart, base)
    if a:findstart
        return 0
    endif

    echo "a:base=" . a:base
    if a:base !~ '^>'
        return []
    endif
    let l:base = a:base[1:]
    echo "l:base=" . l:base

    if strlen(l:base) < g:FuzzyFinder_MinLengthBuffer
        echo ""
        return []
    endif

    let pattern = <SID>MakeFuzzyPattern(l:base, 1)

    " make a list of buffers
    redir => l:lines | silent buffers! | redir END

    let res = []
    for line in split(lines, "\n")
        let bufNr   = matchstr(line, '^\s*\zs\d*')
        let bufInd  = matchstr(line, '^\s*\d*\zs[^"]*')
        let bufName = matchstr(line, '"\zs[^"]*')
        let bufActive = (bufInd =~ 'a' ? '*' : ' ')

        if bufNr == s:bufID || bufInd =~ g:FuzzyFinder_ExcludeIndicator
            continue
        elseif l:base == bufNr || l:base == bufName
            call insert(res, {'word': bufName, 'abbr': bufActive, 'menu': line})
        elseif bufName =~ pattern
            call    add(res, {'word': bufName, 'abbr': bufActive, 'menu': line})
        endif
    endfor

    echo "pattern:" . pattern
    call feedkeys(!empty(res) ? "\<C-P>\<Down>" : "\<C-E>", 'n')

    return res
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! FuzzyFinder_CompleteFile(findstart, base)
    if a:findstart 
        return 0
    endif

    if a:base !~ '^>'
        return []
    endif
    let l:base = a:base[1:]

    let pathHead = matchstr(l:base, '.*[/\\]')
    let pathTail = matchstr(l:base, '[^/\\]*$')
    if strlen(pathTail) < g:FuzzyFinder_MinLengthFile
        echo ""
        return []
    endif

    let pattern = pathHead . <SID>MakeFuzzyPattern(pathTail, 0)

    let res = []
    for path in split(glob(pattern), "\n")
        if isdirectory(path)
            let path = path . g:FuzzyFinder_PathSeparator
        endif
        if l:base == path
            call insert(res, {'word': path, 'menu': '| ' . fnamemodify(path, ':p')})
        else
            call    add(res, {'word': path, 'menu': '| ' . fnamemodify(path, ':p')})
        endif
    endfor

    echo "pattern:" . pattern
    call feedkeys(!empty(res) ? "\<C-P>\<Down>" : "\<C-E>", 'n')

    return res
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>OnCR()
    return pumvisible() ? "\<C-Y>\<C-R>=col('.') > strlen(getline('.')) && getline('.') !~ '[\\\\/]$' ? \"\\<CR>\" : \"\"\<CR>" : "\<CR>"
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>OnCursorMovedI()
    " Fix
    if line('.') != 1 
        call feedkeys("\<Esc>:e " . getline('1') . "\<CR>", 'n')
        return
    endif
    if getline('.') !~ '^>'
        call feedkeys("\<Home>>\<End>", 'n')
        return
    endif

    let deltaInputLength  = strlen(getline('.')) - s:lastInputLength
    let s:lastInputLength = strlen(getline('.'))

    " if the line was changed and cursor is placed on the end of the line
    if deltaInputLength != 0 && col('.') > s:lastInputLength
        call feedkeys("\<C-X>\<C-U>", 'n')
        "call feedkeys("\<C-X>\<C-U>\<C-R>=pumvisible()?\"\\<C-P>\\<Down>\":\"\\<C-E>\"\<CR>", 'n')
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
    if exists(':AutoComplPopUnlock') | :AutoComplPopUnlock | endif

    let &completeopt = s:_completeopt
    let &wildignore  = s:_wildignore
    let s:bufID = -1

    quit " Quit when other window clicked without leaving a insert mode.
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" "str" -> "*s*t*r*" 
function! <SID>MakeFuzzyPattern(str, forRegexp)
    let pattern = ''

    for char in split(a:str,'\zs')
        if pattern =~ '[\*?]$' || char =~ '[\*?]'
            let pattern .= char
        else
            let pattern .= '*' . char
        endif
    endfor

    if pattern !~ '[\*?]$'
        let pattern .= '*'
    endif

    if a:forRegexp
        let pattern = escape(pattern, '\')
        let pattern = substitute(pattern, '*', '\\.\\*', 'g')
        let pattern = substitute(pattern, '?', '\\.'  , 'g')
        let pattern = '\V' . pattern
    endif

    return pattern

endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
