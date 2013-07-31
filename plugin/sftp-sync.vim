" Header.
" --------------------
" sftp-sync.vim
" Maintainer:   https://github.com/eshion/vim-sftp-sync
" Version:      1.0

" Command.
" --------------------
nmap <leader>su :call SftpUpload()<CR>
nmap <leader>sd :call SftpDownload()<CR>
autocmd BufWritePost * :call SftpAutoUpload()
autocmd BufReadPre * :call SftpAutoDownload()

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
    let conf = SftpGetCfg()
    if empty(conf)
        return
    endif    

    let action = printf('put %s %s', conf['local_path'], conf['remote_path'])
    let cmd = printf('
\expect -c "
\set timeout 5; 
\spawn sftp -P %s %s@%s; 
\while {1} {
\   expect -re \"assword:\" {
\       send %s\r;
\   } -re \"Connected\" {
\       send \"%s\r\";
\   } -re \"No such file or directory\" {
\       set timeout -1;
\       send \"mkdir %s\r\";
\       send \"%s\r\";
\   } -re \"100%\" {
\       send \"exit\r\";
\   } timeout {
\       exit;
\   } eof {
\       exit;
\   }
\}
\ "
\', conf['port'], conf['user'], conf['host'], conf['pass'], action, conf['remote_fold'], action)
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

    let conf = SftpGetCfg()
    let action = printf('get %s %s', conf['remote_path'], conf['local_path'])
    let cmd = printf('
\expect -c "
\set timeout 5; 
\spawn sftp -P %s %s@%s; 
\while {1} {
\   expect -re \"assword:\" {
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
\', conf['port'], conf['user'], conf['host'], conf['pass'], action)

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
    let tc = SftpGetCfg()
    if empty(tc) || empty(tc['download_on_open']) || tc['download_on_open'] == 0
        return
    endif
    call SftpDownload()
endfunction

function! SftpAutoUpload()
    let tc = SftpGetCfg()
    if empty(tc) || empty(tc['upload_on_save']) || tc['upload_on_save'] == 0
        return
    endif
    call SftpUpload()
endfunction
