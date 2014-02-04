" Header.
" --------------------
" sftp-sync.vim
" Maintainer:   https://github.com/eshion/vim-sftp-sync
" Version:      1.1

" Command.
" --------------------
let s:sftp_command = "sftp"
let s:login_prompt_regexp = "Login:\\|Name.*:"
let s:password_prompt_regexp = "Password:"
let s:sftp_prompt_regexp = "^s*ftp>"
let s:complete_prompt_regexp = "complete"
let s:upload_command = "put"
let s:download_command = "get"
let s:exit_command = "exit"
let s:timeout_connection = 5
let s:upload_on_save = 0
let s:confirm_uploads = 1
let s:confirm_downloads = 1

function! SftpGetCfg()

  if !exists("g:vim_sftp_configs")
    return
  endif

  let configs = g:vim_sftp_configs
  let self_path = expand("%:p")
  let self_fold = expand("%:p:h")

  for key in keys(configs)
    let config = configs[key]
    let local_base_path = config['local_base_path']
    if self_path =~ "^" . local_base_path
      let target_config        = config
      let target_project       = key
      let target_relative_path = self_path[strlen(local_base_path):]
      let target_relative_fold = self_fold[strlen(local_base_path):]
    endif
  endfor

  if !exists("target_project")
    return
  endif

  let local_full_path  = target_config['local_base_path']  . target_relative_path
  let remote_full_path = target_config['remote_base_path'] . target_relative_path
  let remote_full_fold = target_config['remote_base_path'] . target_relative_fold

  if self_path != local_full_path
    echo "self_path is not local_full_path. expect is same."
  endif

  let target_config['local_path'] = local_full_path
  let target_config['remote_path'] = remote_full_path
  let target_config['remote_fold'] = remote_full_fold

  return target_config
endfunction

function! s:makeExpectStr(arg)
  let arg = a:arg
  let str = []
  for [k, v] in items(arg)
    call add(str, printf('-re \"%s\" { send \"%s\r\"; }', k, v))
  endfor
  return join(str, ' ')
endfunction

" type=0 download
" type=1 update
function! s:makeCmdStr(type) 
  if exists('s:conf')
    let conf = s:conf
    unlet s:conf
  else
    let conf = SftpGetCfg()
  endif
  if empty(conf)
    echo "remote config not found"
    return
  endif
  if a:type == 1 "upload
    if conf['confirm_uploads']==1
      let choice = confirm("Can I upload this file?", "&Yes\n&No", 2)
      if choice != 1
        echo "Cenceled."
        return
      endif
    endif
    let action    = has_key(conf, 'upload_command') ? conf['upload_command'] : s:upload_command
    let action    = printf('%s %s %s', action, conf['local_path'], conf['remote_path'])
  else
    if conf['confirm_downloads']==1
      let choice = confirm("Can I download this file?", "&Yes\n&No", 2)
      if choice != 1
        echo "Cenceled."
        return
      endif
    endif
    let action    = has_key(conf, 'download_command') ? conf['download_command'] : s:download_command
    let action    = printf('%s %s %s', action, conf['remote_path'], conf['local_path'])
  endif
  let sftp_cmd  = has_key(conf, 'sftp_command') ? conf['sftp_command'] : s:sftp_command
  let login_reg = has_key(conf, 'login_prompt_regexp') ? conf['login_prompt_regexp'] : s:login_prompt_regexp
  let psw_reg   = has_key(conf, 'password_prompt_regexp') ? conf['password_prompt_regexp'] : s:password_prompt_regexp
  let prpt_reg  = has_key(conf, 'sftp_prompt_regexp') ? conf['sftp_prompt_regexp'] : s:sftp_prompt_regexp
  let cmpl_reg  = has_key(conf, 'complete_prompt_regexp') ? conf['complete_prompt_regexp'] : s:complete_prompt_regexp
  let timeout   = has_key(conf, 'timeout_connection') ? conf['timeout_connection'] : s:timeout_connection
  let exit_cmd  = has_key(conf, 'exit_command') ? conf['exit_command'] : s:exit_command

  let arg = {}
  let arg[login_reg] = conf['user']
  let arg[psw_reg] = conf['pass']
  if a:type == 1 "upload and no directory
    let arg['No such file or directory'] = 'mkdir '.conf['remote_fold'] .'\r '.action
  endif
  let arg[prpt_reg] = action
  let arg[cmpl_reg] = exit_cmd
  let arg['not found'] = exit_cmd
  let expect = s:makeExpectStr(arg)
  let cmd = printf('expect -c "set timeout %d; spawn %s %s; while {1} { expect %s timeout {exit;} eof {exit;} }"', timeout, sftp_cmd, conf['host'], expect)
  return cmd
endfunction

function! SftpUpload()
  let cmd = s:makeCmdStr(1)
  if !empty(cmd)
    execute '!' . cmd
  endif
endfunction


function! SftpDownload()
  let cmd = s:makeCmdStr(0)
  if !empty(cmd)
    execute '!' . cmd
  endif
endfunction

function! SftpAutoDownload()
  let s:conf = SftpGetCfg()
  if empty(s:conf) || empty(s:conf['download_on_open']) || s:conf['download_on_open'] == 0
    unlet s:conf
    return
  endif
  call SftpDownload()
endfunction

function! SftpAutoUpload()
  let s:conf = SftpGetCfg()
  if empty(s:conf) || empty(s:conf['upload_on_save']) || s:conf['upload_on_save'] == 0
    unlet s:conf
    return
  endif
  call SftpUpload()
endfunction

nmap <leader>su :call SftpUpload()<CR>
nmap <leader>sd :call SftpDownload()<CR>
autocmd BufWritePost * :call SftpAutoUpload()
autocmd BufReadPre * :call SftpAutoDownload()
