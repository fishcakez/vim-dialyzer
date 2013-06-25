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
if exists('current_compiler')
    finish
endif
let current_compiler = 'dialyzer'

if exists(':CompilerSet') != 2
    command -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=dialyzer

CompilerSet errorformat=
            \%f:%l:\ %tarning:\ %m,
            \%f:%l:\ %m,
            \%+Gdialyzer:%.%#,
            \%+IThe\ PLT\ %.%#\ includes\ the\ following\ files:,
            \%+C\[%.%#,
            \%+C%\\s%\\+\"%.%#,
            \%-Z%\\s%#,
            \%\\s%#Check\ output\ file\ `%f'\ %m,
            \%+EUnknown%.%#,
            \%+CUnknown%.%#,
            \%+C%\\s%\\+%.%\\+:%.%\\+/%\\d%\\+\\s%#,
            \%-Z%\\s%\\+done\ in%.%#,
            \%-G%.%#

let &cpo = s:cpo_save
unlet s:cpo_save
