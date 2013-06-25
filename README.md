vim-dialyzer
============
A vim plugin to make using dialyzer easier and faster from inside vim.

Features
--------
- Asynchronous

- Quickfix

- Command completion

Install
-------
- Install `dispatch.vim` (https://github.com/tpope/vim-dispatch)

- Clone this repo into your vim-path. With pathogen.vim would be:

```
cd ~/.vim/bundle && git clone https://github.com/fishcakez/vim-dialyzer.git
```

Usage
-----
Exactly the same as `dialyzer`; to run `dialyzer --plt app.plt ebin`:
```
:Dialyzer --plt app.plt ebin
```
Or in the background
```
:Dialyzer! --plt app.plt ebin
```
Then to create quickfix list:
```
:Copen
```
Or to view all the output in a quickfix list:
```
:Copen!
```
To run `dialyzer` in a new, focused, window (no quickfix support):
```
:Dialyzer!! --build_plt --output_plt .plt --apps erts kernel stdlib
```
To run `dialyzer` in a new, unfocused, window (no quickfix support):
```
:Dialyzer!!! --build_plt --output_plt .plt --apps erts kernel stdlib
```
