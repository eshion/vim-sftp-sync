" Header.
" --------------------
" sftp-sync.vim
" Maintainer:   https://github.com/eshion/vim-sftp-sync
" Version:      1.1

" Command.
" --------------------
let s:sftp_command = "sftp"
let s:login_prompt_regexp = "Login:\\|Name.*:"
let s:password_prompt_regexp = "assword:"
let s:sftp_prompt_regexp = "^s*ftp>"
let s:update_command = "put"
let s:download_command = "get"
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

function! SftpUpload()
  let conf = exists(s:conf) ? s:conf : SftpGetCfg()
  unlet s:conf
  if empty(conf)
    echo "not found remote config"
    return
  endif
  let sftp_cmd  = exists(conf['sftp_command']) ? conf['sftp_command'] : s:sftp_command
  let action    = exists(conf['upload_on_save']) ? conf['update_command'] : s:update_command
  let login_reg = exists(conf['login_prompt_regexp']) ? conf['login_prompt_regexp'] : s:login_prompt_regexp
  let psw_reg   = exists(conf['password_prompt_regexp']) ? conf['password_prompt_regexp'] : s:password_prompt_regexp
  let timeout   = exists(conf['timeout_connection']) ? conf['timeout_connection'] : s:timeout_connection
  let action    = printf('%s %s %s', action, conf['local_path'], conf['remote_path'])
  let cmd = printf('
        \expect -c "
        \set timeout %d; 
        \spawn %s %s; 
        \while {1} {
        \   expect -re \"%s\" {
        \       send %s\r;
        \   } -re \"%s\" {
        \       send %s\r;
        \   } -re \"Connected\" {
        \       send \"%s\r\";
        \   } -re \"No such file or directory\" {
        \       send \"mkdir %s\r\";
        \       send \"%s\r\";
        \   } -re \"100%\" {
        \       send \"exit\r\";
        \   } -re \"not found\" {
        \       send \"exit\r\";
        \   } timeout {
        \       exit;
        \   } eof {
        \       exit;
        \   }
        \}
        \ "
        \', timeout, sftp_cmd, conf['host']
        \, login_reg, conf['user'], psw_reg, conf['pass'], action, conf['remote_fold'], action)
  if conf['confirm_uploads']==1
    let choice = confirm("Can I upload this file?", "&Yes\n&No", 2)
    if choice != 1
      echo "Cenceled."
      return
    endif
  endif

  execute '!' . cmd

endfunction


function! SftpDownload()
  let conf = exists(s:conf) ? s:conf : SftpGetCfg()
  unlet s:conf
  if empty(conf)
    echo "not found remote config"
    return
  endif
  let sftp_cmd  = exists(conf['sftp_command']) ? conf['sftp_command'] : s:sftp_command
  let action    = exists(conf['download_command']) ? conf['download_command'] : s:download_command
  let login_reg = exists(conf['login_prompt_regexp']) ? conf['login_prompt_regexp'] : s:login_prompt_regexp
  let psw_reg   = exists(conf['password_prompt_regexp']) ? conf['password_prompt_regexp'] : s:password_prompt_regexp
  let timeout   = exists(conf['timeout_connection']) ? conf['timeout_connection'] : s:timeout_connection
  let action    = printf('%s %s %s', action, conf['remote_path'], conf['local_path'])
  let cmd = printf('
        \expect -c "
        \set timeout %d; 
        \spawn %s %s; 
        \while {1} {
        \   expect -re \"%s\" {
        \       send %s\r;
        \   } -re \"%s\" {
        \       send %s\r;
        \   } -re \"Connected\" {
        \       send \"%s\r\";
        \   } -re \"100%\" {
        \       send \"exit\r\";
        \   } -re \"not found\" {
        \       send \"exit\r\";
        \   } timeout {
        \       exit;
        \   } eof {
        \       exit;
        \   }
        \}
        \ "
        \', timeout, sftp_cmd, conf['host']
        \, login_reg, conf['user'], psw_reg, conf['pass'], action)

  if conf['confirm_downloads']==1
    let choice = confirm("Can I download this file?", "&Yes\n&No", 2)
    if choice != 1
      echo "Cenceled."
      return
    endif
  endif
  execute '!' . cmd
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
