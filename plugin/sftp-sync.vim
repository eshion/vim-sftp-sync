" Header.
" --------------------
" sftp-sync.vim
" Maintainer:   https://github.com/eshion/vim-sftp-sync
" Version:      1.0

" Command.
" --------------------
map <silent>sftpu <ESC>:call SftpUpload()<CR>
map <silent>sftpd <ESC>:call SftpDownload()<CR>
autocmd BufWritePost * :call SftpAutoUpload()
autocmd BufReadPre * :call SftpAutoDownload()

function! SftpGetCfg()

    if !exists("g:vim_sftp_configs")
        return
    endif

    let configs = g:vim_sftp_configs
    let self_path = expand("%:p")

    for key in keys(configs)
        let config = configs[key]
        let local_base_path = config['local_base_path']
        if self_path =~ "^" . local_base_path
            let target_config        = config
            let target_project       = key
            let target_relative_path = self_path[strlen(local_base_path):]
        endif
    endfor

    if !exists("target_project")
        return
    endif

    let local_full_path  = target_config['local_base_path']  . target_relative_path
    let remote_full_path = target_config['remote_base_path'] . target_relative_path

    if self_path != local_full_path
        echo "self_path is not local_full_path. expect is same."
    endif

    let target_config['local_path'] = local_full_path
    let target_config['remote_path'] = remote_full_path

    return target_config
endfunction

function! SftpUpload()
    let tc = SftpGetCfg()
    if empty(tc)
        return
    endif    
    let cmd = printf('sh ~/.vim/bundle/vim-sftp-sync/sftp.sh %s %s %s %s "put %s %s"',tc['host'], tc['port'],tc['user'],tc['pass'], tc['local_path'], tc['remote_path'])
    "echo cmd
    "echo 'local_path:' . tc['local_path']
    "echo 'remote_path:' . tc['remote_path']
    if tc['confirm_uploads']==1
        let choice = confirm("Can I upload this file?", "&Yes\n&No", 2)
        if choice != 1
            echo "Cenceled."
            return
        endif
    endif

    execute '!' . cmd

endfunction


function! SftpDownload()

    let tc = SftpGetCfg()
    let cmd = printf('sh ~/.vim/bundle/vim-sftp-sync/sftp.sh %s %s %s %s "get %s %s"',tc['host'], tc['port'],tc['user'],tc['pass'], tc['remote_path'], tc['local_path'])
    "echo cmd
    echo 'local_path:' . tc['local_path']
    echo 'remote_path:' . tc['remote_path']


    if tc['confirm_downloads']==1
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
