### Please note! vim-sftp-sync has been superseded by [vim-sync].


vim-sftp-sync
============

Automatic sync SFTP,FTP,... for buffers in vim.


Installation
----

Install using [bundle],[vundle],[pathogen] or your favorite Vim package manager.

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
    \		'sftp_command' : 'ftp',
    \		'user' : 'username',
    \		'pass' : 'password',
    \		'host' : '127.0.0.1'
    \	},
    \	'sample_server_2' : {
    \       'upload_on_save'   : 1,
    \    	'download_on_open' : 1,
    \    	'confirm_downloads': 0,
    \    	'confirm_uploads'  : 0,
    \		'local_base_path'  : '/Users/development',
    \		'remote_base_path' : '/var/www/development/trunk/',
    \		'sftp_command' : 'sftp',
    \       'complete_prompt_regexp' : '100\%',
    \		'user' : 'username',
    \		'pass' : 'password',
    \		'host' : '-P23 user@127.0.0.1'
    \	}
    \}

sample1
 > Edit sftp file : /Users/name/sample/file.php  
 > Sync to : /var/www/sample/file.php

sample2
 > Edit ftp file : /Users/name/sample/lib/dao/file.php  
 > Sync to : /var/www/sample/lib/dao/file.php

All parameters
----

local_base_path:
 > local base path
 
remote_base_path:
 > remote base path
 
host:
 > remote ip or host name
 
user:
 > login user
 
pass:
 > login password
 
sftp_command:   
 > sync tool command  
 > default: "sftp"

login_prompt_regexp: 
 > login name prompt regexp  
 > default: "Login:\\|Name.*:"

password_prompt_regexp: 
 > login password prompt regexp  
 > default: "P\|password:"

sftp_prompt_regexp: 
 > logged prompt regexp  
 > default: "sftp>"

complete_prompt_regexp:
 > complete sync prompt regexp  
 > default: "complete"

upload_command:
 > upload command  
 > default: "put"

download_command:
 > download command  
 > default: "get"

exit_command:
 > exit command  
 > default: "exit"

timeout_connection:
 > timeout second(s)  
 > default: 5

upload_on_save:
 > default: 0

confirm_uploads:
 > default: 1

confirm_downloads:
 > default: 1


Alias
----
  
If you want to another command, write following like.

Ctrl+u  
    `nnoremap <C-U> <ESC>:call SftpUpload()<CR>`
    
Ctrl+d  
    `nnoremap <C-D> <ESC>:call SftpDownload()<CR>`
    
[vim-sync]:https://github.com/eshion/vim-sync/
[bundle]:https://github.com/bundler/bundler/
[vundle]:https://github.com/gmarik/vundle/
[pathogen]:https://github.com/tpope/vim-pathogen/
