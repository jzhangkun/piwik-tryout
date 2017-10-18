# piwik-tryout
tryout piwik analytics 

## Apache Initial Configuration
By default the Apache installation doesn’t have the PHP directives configured so it necessary to add them to the httpd.conf file

Within Vi search for the LoadModule section and add the following line 
```
LoadModule php5_module /usr/lib64/httpd/modules/libphp5.so

```

Search for AddOutputFilter INCLUDES .shtml within the file and under that line add
```
<FilesMatch \.php$>
SetHandler application/x-httpd-php
</FilesMatch>
```

To disable Directory Listing search for Options and change the following line

```
	Options Indexes FollowSymLinks 
```
To
```
	Options FollowSymLinks
```

To enable automatic redirecting to the Piwik home page search for Redirect and add the following lines in
```
RedirectMatch ^/$ /piwik/index.php
RedirectMatch ^/piwik/$ /piwik/index.php
```

This will redirect the top level root URL to the piwik default page. 
