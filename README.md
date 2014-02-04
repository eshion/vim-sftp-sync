vim-sftp-sync
============

Automatic sync SFTP,FTP,... for buffers in vim


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
    \		'sftp_command' : 'sftp',
    \		'user' : 'username',
    \		'pass' : 'password',
    \		'host' : 'ip addess or domain name'
    \	},
    \	'sample_server_2' : {
    \       'upload_on_save'   : 1,
    \    	'download_on_open' : 1,
    \    	'confirm_downloads': 0,
    \    	'confirm_uploads'  : 0,
    \		'local_base_path'  : '/Users/development',
    \		'remote_base_path' : '/var/www/development/trunk/',
    \		'sftp_command' : 'ftp',
    \		'user' : 'username',
    \		'pass' : 'password',
    \		'host' : 'ip addess or domain name'
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

remote_base_path:

host:

user:

pass:

sftp_command:   
    default: "sftp"

login_prompt_regexp: 
    default: "Login:\\|Name.*:"

password_prompt_regexp: 
    default: "Password:"

sftp_prompt_regexp: 
    default: "^s*ftp>"

complete_prompt_regexp:
    default: "complete"

update_command:
    default: "put"

download_command:
    default: "get"

exit_command:
    default: "exit"

timeout_connection:
    default: 5

upload_on_save:
    default: 0

confirm_uploads:
    default: 1

confirm_downloads:
    default: 1


Alias
----
  
If you want to another command, write following like.

Ctrl+u  
    `nnoremap <C-U> <ESC>:call SftpUpload()<CR>`
    
Ctrl+d  
    `nnoremap <C-U> <ESC>:call SftpDownload()<CR>`
    
[bundle]:https://github.com/bundler/bundler/
[vundle]:https://github.com/gmarik/vundle/
[pathogen]:https://github.com/tpope/vim-pathogen/
