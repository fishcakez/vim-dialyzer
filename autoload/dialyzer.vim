" Copyright 2013 James Fish
"
" Licensed under the Apache License, Version 2.0 (the "License");
" you may not use this file except in compliance with the License.
" You may obtain a copy of the License at
"
"     http://www.apache.org/licenses/LICENSE-2.0
"
" Unless required by applicable law or agreed to in writing, software
" distributed under the License is distributed on an "AS IS" BASIS,
" WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
" See the License for the specific language governing permissions and
" limitations under the License.
if exists('g:autoloaded_dialyzer')
    finish
endif
let g:autoloaded_dialyzer = 1

function! dialyzer#dispatch(bang, args)
    let args = join(a:args)
    let [bangs, dialyzerargs] = dialyzer#split_args(args)
    let cmd = 'dialyzer ' . dialyzerargs . ' --fullpath'
    if exists(':Dispatch') && exists(':Start')
        if strlen(bangs) == 0
            execute 'Dispatch' . a:bang cmd
        else
            let bang = (strlen(bangs) > 1) ? '!' : ''
            execute 'Start' . bang cmd
        endif
    else
        return dialyzer#compile_command(a:bang, dialyzerargs)
    endif
endfunction

function! dialyzer#split_args(args)
    "match leading !'s and the remainder
    return matchlist(a:args, '\(!*\)\(.*\)')[1:2]
endfunction

function! dialyzer#compile_command(bang, args)
    let compiler_info = dialyzer#get_compiler_info()
    if &autowrite
        wall
    endif
    try
        execute 'compiler dialyzer'
        execute 'make' . a:bang a:args
    finally
        call dialyzer#set_compiler_info(compiler_info)
    endtry
    return ''
endfunction

function! dialyzer#get_compiler_info()
    return [get(b:, 'current_compiler', ''), &l:makeprg, &l:efm]
endfunction

function! dialyzer#set_compiler_info(compiler_info)
    let [name, &l:makeprg, &l:efm] = a:compiler_info
    if empty(name)
        unlet! b:current_compiler
    else
        let b:current_compiler = name
    endif
endfunction

function! dialyzer#complete(arglead, cmdline, cursorpos)
    let [dialyzer_and_bangs, cmdline] =
                \ matchlist(a:cmdline, '^\([^ ]*\)\(.*\)$')[1:2]
    " cursorpos is on extra bangs, can't offer any completion
    if (a:cursorpos <= strlen(dialyzer_and_bangs)) || (a:cmdline == cmdline)
        return ''
    else
        let cursorpos = a:cursorpos - strlen(dialyzer_and_bangs)
        let suggestions = dialyzer#complete#list(a:arglead, cmdline, cursorpos)
        return join(suggestions, "\n")
    endif
endfunction
