" textobj-fold - Text objects for date and time.
" Version: 0.1.1
" Copyright (C) 2008 kana <http://whileimautomaton.net/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
if exists('g:loaded_textobj_fold')  "{{{1
  finish
endif








" Interface  "{{{1

call textobj#user#plugin('fold', {
\      '-': {
\        '*sfile*': expand('<sfile>:p'),
\        'select-a': 'az',  '*select-a-function*': 's:select_a',
\        'select-i': 'iz',  '*select-i-function*': 's:select_i'
\      }
\    })








" Misc.  "{{{1
" Core  "{{{2
function! s:select_a(previous_mode)
  call s:prepare_selection(a:previous_mode)

  call s:move_to_the_start_point()
  let selection_starts_with_fold_p = !s:in_non_fold_p()
  let start_pos = getpos('.')
  for i in range(v:count1 - 1)
    call s:move_to_the_end_point('a', selection_starts_with_fold_p)
    normal! j
  endfor
  call s:move_to_the_end_point('a', selection_starts_with_fold_p)
  let end_pos = getpos('.')

  call setpos('.', start_pos)
  call s:start_visual_mode()
  call setpos('.', end_pos)

  return
endfunction

function! s:select_i(previous_mode)
  call s:prepare_selection(a:previous_mode)

  call s:move_to_the_start_point()
  let start_pos = getpos('.')
  for i in range(v:count1 - 1)
    call s:move_to_the_end_point('i', 0)
    normal! j
  endfor
  call s:move_to_the_end_point('i', 0)
  let end_pos = getpos('.')

  call setpos('.', start_pos)
  call s:start_visual_mode()
  call setpos('.', end_pos)

  return
endfunction




" Movement  "{{{2
function! s:move_to_the_start_point()
  if s:in_open_fold_p()
    call s:move_to_the_start_of_open_fold()
  elseif s:in_closed_fold_p()
    " call s:move_to_the_start_of_closed_fold()  " already at the point.
  else
    call s:move_to_the_start_of_non_fold()
  endif
endfunction

function! s:move_to_the_start_of_open_fold()
  let level = foldlevel(line('.'))
  normal! [z
  if foldlevel(line('.')) < level
    normal! ``
  endif
endfunction

function! s:move_to_the_start_of_non_fold()
  let orig_line = line('.')
  normal! zk
  if orig_line != line('.')
    normal! j
  else  " this buffer starts with the current non fold.
    normal! 1G
  endif
endfunction


function! s:move_to_the_end_point(mode, selection_starts_with_fold_p)
  if s:in_open_fold_p()
    call s:move_to_the_end_of_open_fold()
  elseif s:in_closed_fold_p()
    " call s:move_to_the_end_of_closed_fold()  " already at the point.
  else
    call s:move_to_the_end_of_non_fold()
  endif

  " To behave like v_aw, count the folding lines and leading or trailing
  " non-folding lines as 1 text object.  For example:
  "
  " (a)  N|F N F  ==>  N F N F
  "                      ^^^
  "
  " (b)  N|F F N  ==>  N F F N
  "                      ^  
  "
  " (c) |N F N F  ==>  N F N F
  "                    ^^^
  "
  " (d) |N F F N  ==>  N F F N
  "                    ^^^
  "
  " Note: in the above figures,
  "       F means lines in a fold,
  "       N means lines not in a fold, and
  "       | means the cursor (which is at one of the next character's lines),
  "       ^ means the current selection.
  "
  " FIXME: Not implemented yet.
  if a:mode ==# 'a'
    if a:selection_starts_with_fold_p
      if s:in_non_fold_p()
      else
      endif
    else
      if s:in_non_fold_p()
      else
      endif
    endif
  endif
endfunction

function! s:move_to_the_end_of_open_fold()
  let level = foldlevel(line('.'))
  normal! ]z
  if foldlevel(line('.')) < level
    normal! ``
  endif
endfunction

function! s:move_to_the_end_of_non_fold()
  let orig_line = line('.')
  normal! zj
  if orig_line != line('.')
    normal! k
  else  " this buffer ends with the current non fold.
    normal! G
  endif
endfunction




" Predicates  "{{{2
function! s:in_open_fold_p()
  return foldclosed(line('.')) < 0 && 0 < foldlevel(line('.'))
endfunction


function! s:in_closed_fold_p()
  return 0 < foldclosed(line('.'))
endfunction


function! s:in_non_fold_p()
  return foldlevel(line('.')) == 0
endfunction




" Etc  "{{{2
function! s:start_visual_mode()
  normal! V
endfunction


function! s:prepare_selection(previous_mode)
  if a:previous_mode ==# 'v'
    execute 'normal!' "gv\<Esc>"
  endif
endfunction








" Fin.  "{{{1

let g:loaded_textobj_fold = 1








" __END__
" vim: foldmethod=marker
