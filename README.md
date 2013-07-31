vim-sftp-sync
============

Automatic sync SFTP for buffers in vim


Installation
----

Install using [vundle],[pathogen] or your favorite Vim package manager.

Usage
----
    <leader>su
    Upload the file
    
    <leader>sd
    Download the file

Description
----

Please write config following like.

    let g:vim_sftp_configs = {
    \      'sample_server_1' : {
    \    	'upload_on_save'   : 1,
    \    	'download_on_open' : 0,
    \    	'confirm_downloads': 1,
    \    	'confirm_uploads'  : 0,
    \		'local_base_path'  : '/Users/name/sample/',
    \		'remote_base_path' : '/var/www/sample/',
    \		'user' : 'username',
    \		'pass' : 'password',
    \		'host' : 'ip addess or domain name',
    \		'port' : '22'
    \	},
    \	'sample_server_2' : {
    \       'upload_on_save'   : 1,
    \    	'download_on_open' : 1,
    \    	'confirm_downloads': 0,
    \    	'confirm_uploads'  : 0,
    \		'local_base_path'  : '/Users/development',
    \		'remote_base_path' : '/var/www/development/trunk/',
    \		'user' : 'username',
    \		'pass' : 'password',
    \		'host' : 'ip addess or domain name',
    \		'port' : '22'
    \	}
    \}

sample1
 > Edit file : /Users/name/sample/file.php  
 > Sync to : /var/www/sample/file.php

sample2
 > Edit file : /Users/name/sample/lib/dao/file.php  
 > Sync to : /var/www/sample/lib/dao/file.php

Alias
----
  
If you want to another command, write following like.

Ctrl+u  
    `nnoremap <C-U> <ESC>:call SftpUpload()<CR>`
    
Ctrl+d  
    `nnoremap <C-U> <ESC>:call SftpDownload()<CR>`
    
[vundle]:https://github.com/gmarik/vundle/
[pathogen]:https://github.com/tpope/vim-pathogen/
