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
if exists('g:autoloaded_dialyzer_complete')
    finish
endif
let g:autoloaded_dialyzer_complete = 1

" return a list of suggestions
function! dialyzer#complete#list(arglead, cmdline, cursorpos)
    let optprev = dialyzer#complete#optprev(a:arglead, a:cmdline, a:cursorpos)
    let argprev = dialyzer#complete#argprev(a:arglead, a:cmdline,
                    \a:cursorpos)
    let greedy_info = dialyzer#complete#greedy_info()
    let opts_info = dialyzer#complete#opts_info()
    if has_key(greedy_info, optprev) && (a:arglead !~ '^-')
        let opt_val = get(greedy_info, optprev, [])
        let suggested_opt_vals = dialyzer#complete#eval(opt_val)
        let suggested_opts = sort(keys(opts_info) + keys(greedy_info))
        return suggested_opt_vals + suggested_opts
    else
        let opt_val = get(opts_info, argprev, 0)
        if (type(opt_val) != type(1)) || (opt_val != 0) && (a:arglead !~ '^-')
            return dialyzer#complete#eval(opt_val)
        else
            let suggested_files = dialyzer#complete#file_list(a:cmdline)
            let suggested_opts = sort(keys(opts_info) + keys(greedy_info))
            return suggested_files + suggested_opts
        endif
    endif
endfunction

" get previous option
function! dialyzer#complete#optprev(arglead, cmdline, cursorpos)
    let before = a:cmdline[0:a:cursorpos-strlen(a:arglead)-1]
    let beforelist = reverse(split(before, ' '))
    for argvalue in beforelist
        if argvalue =~ '^-'
            return argvalue
        endif
    endfor
    return ''
endfunction

" get previous argument
function! dialyzer#complete#argprev(arglead, cmdline, cursorpos)
    let before = a:cmdline[0:a:cursorpos-strlen(a:arglead)-1]
    return matchlist(before, '\([^ ]*\)\s*$')[1]
endfunction

" eval an option value
function! dialyzer#complete#eval(value)
    let suggestions = []
    for Elem in a:value
        if type(Elem) == type('')
            call add(suggestions, Elem)
        elseif type(Elem) == type(function('strlen'))
            call extend(suggestions, Elem())
        elseif Elem != 0
            echomsg 'Invalid Info'
        endif
        " unlet Elem as could be function or string
        unlet Elem
    endfor
    return suggestions
endfunction

" list possible files
function! dialyzer#complete#file_list(cmdline)
    if a:cmdline =~ '-r'
        let recursive = dialyzer#complete#recursive_list()
    else
        let recursive = []
    endif
    if a:cmdline =~ '--src'
        return recursive + dialyzer#complete#src_list()
    else
        return recursive + dialyzer#complete#ebin_list()
    endif
endfunction

" dictionary for options
function! dialyzer#complete#opts_info()
    return
                \{
                \'--help' : 0,
                \'--version' : 0,
                \'--shell' : 0,
                \'--quiet' : 0,
                \'--verbose' : 0,
                \'-pa' : [function('dialyzer#complete#ebin_list')],
                \'--plt' : [function('dialyzer#complete#plt_list')],
                \'-D' : 0,
                \'-I' : [function('dialyzer#complete#include_list')],
                \'--output_plt' :
                    \[
                        \function('dialyzer#complete#plt_out'),
                        \function('dialyzer#complete#plt_list')
                    \],
                \'-Whelp' : 0,
                \'-Wno_return' : 0,
                \'-Wno_unused' : 0,
                \'-Wno_improper_lists' : 0,
                \'-Wno_tuple_as_fun' : 0,
                \'-Wno_fun_app' : 0,
                \'-Wno_match' : 0,
                \'-Wno_opaque' : 0,
                \'-Wno_behaviours' : 0,
                \'-Wunmatched_returns' : 0,
                \'-Werror_handling' : 0,
                \'-Wrace_conditions' : 0,
                \'-Wunderspecs' : 0,
                \'-Woverspecs' : 0,
                \'-Wspecdiffs' : 0,
                \'--src' : 0,
                \'--gui' : 0,
                \'--wx' : 0,
                \'-r' : 0,
                \'-o' : ['.dialyzer_output'],
                \'--build_plt': 0,
                \'--add_to_plt' : 0,
                \'--remove_from_plt' : 0,
                \'--check_plt' : 0,
                \'--no_check_plt' : 0,
                \'--plt_info' : 0,
                \'--get_warnings' : 0,
                \'--no_native' : 0,
                \'--fullpath' : 0
                \}
endfunction

" dictionary for options that use all values until the next option
function! dialyzer#complete#greedy_info()
    return
                \{
                \'--plts' : [function('dialyzer#complete#plt_list')],
                \'--apps' :
                    \[
                        \function('dialyzer#complete#apps_default'),
                        \function('dialyzer#complete#appid'),
                        \function('dialyzer#complete#apps_deps'),
                        \function('dialyzer#complete#apps_otp')
                    \]
                \}
endfunction

" suggest some recursive dirs
function! dialyzer#complete#recursive_list()
    let dirnames = ['apps', 'deps', 'lib']
    let dirs = []
    for dir in dirnames
        let dirs2 = split(globpath('.', dir . '/'), "\n")
        call extend(dirs, dirs2)
    endfor
    return dirs
endfunction

" list all **/src/
function! dialyzer#complete#src_list()
    return dialyzer#complete#dir_list('src')
endfunction

" list all dirs /a:dirname/ or **/a:dirname/
function! dialyzer#complete#dir_list(dirname)
    return split(globpath('.', a:dirname . '/'), "\n") +
                \split(globpath('.', '**/' . a:dirname . '/'), "\n")
endfunction

" list all **/ebin/
function! dialyzer#complete#ebin_list()
    return dialyzer#complete#dir_list('ebin')
endfunction

" list all **/include/
function! dialyzer#complete#include_list()
    return dialyzer#complete#dir_list('include')
endfunction

" list all .plts
function! dialyzer#complete#plt_list()
    return split(globpath('.', '**/.*.plt'), "\n") +
                \split(globpath('.', '**/*.plt'), "\n")
endfunction

" suggest plt out as '.(dirname).plt'
function! dialyzer#complete#plt_out()
    let [appid] = dialyzer#complete#appid()
    return ['.' . appid . '.plt']
endfunction

" list apps that should always be used
function! dialyzer#complete#apps_default()
    return
                \[
                \'erts',
                \'kernel',
                \'stdlib'
                \]
endfunction

" suggest dirname as appid.
function! dialyzer#complete#appid()
    return [fnamemodify(expand(getcwd()), ":t")]
endfunction

" list possible app names
function! dialyzer#complete#apps_deps()
    let apps = {}
    let patterns = ['apps/*/', 'deps/*/', 'deps/*/apps/*/']
    for pat in patterns
        for dir in split(globpath('.', pat), "\n")
            let app = fnamemodify(dir, ':h:t')
            let apps[app] = 1
        endfor
    endfor
    return sort(keys(apps))
endfunction

" list all non-default otp apps
function! dialyzer#complete#apps_otp()
    return
                \[
                \'appmon',
                \'asn1',
                \'common_test',
                \'compiler',
                \'cosEvent',
                \'cosEventDomain',
                \'cosFileTransfer',
                \'cosNotification',
                \'cosProperty',
                \'cosTime',
                \'cosTransactions',
                \'crypto',
                \'debugger',
                \'dialyzer',
                \'edoc',
                \'eldap',
                \'erl_docgen',
                \'erl_interface',
                \'et',
                \'eunit',
                \'gs',
                \'hipe',
                \'ic',
                \'inets',
                \'jinterface',
                \'megaco',
                \'mnesia',
                \'observer',
                \'odbc',
                \'orber',
                \'os_mon',
                \'otp_mibs',
                \'parse_tools',
                \'percept',
                \'pman',
                \'public_key',
                \'reltool',
                \'runtime_tools',
                \'sasl',
                \'ssh',
                \'ssl',
                \'syntax_tools',
                \'test_server',
                \'toolbar',
                \'tools',
                \'tv',
                \'type',
                \'webtool',
                \'wx',
                \'xmerl'
                \]
endfunction
