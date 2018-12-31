# Insight Environment

This image represents the development environment for the Insight ERP, updated with PHP 7.2.  This includes all of the required PHP modules to allow Insight to run.  This image is based on CentOS and Apache 2.4 because that is the current production system configuration.

The image has been configured to accept a couple of different environment variables that will activate debugging features and set other container options at runtime.

NOTE: XDebug is installed via PECL but it isn't active by default.

## Environment Variables
| Variable Name | Valid Value(s) | Default Value | Configuration Value | Notes |
|---|---|---|---|---|
|APACHE_SERVER_NAME|`string`|localhost|ServerName|Sets the Apache ServerName variable in global context|
|APP_ENV|`development,staging,production`|development|SetEnv INSIGHT_ENV|Sets the Insight environment|
|XDEBUG_REMOTE_ENABLE|`1,0`|0|xdebug.remote_enable|Enables the remote debugger and if necessary the XDebug extension|
|XDEBUG_REMOTE_HANDLER|`string`|dbgp|xdebug.remote_handler|Sets the debugger protocol, you should leave this at it's default value|
|XDEBUG_REMOTE_IP|`string`|127.0.0.1|xdebug.remote_host|The remote host (IP or DNS name) to send the send the debug info (PC or Mac should be host.docker.internal, that's the DNS name of the host PC)|
|XDEBUG_REMOTE_PORT|`integer`|9000|xdebug.remote_port|The port to send debug info to|
|XDEBUG_IDE_KEY|`string`|IDE_KEY|xdebug.idekey|The COOKIE/GET/POST parameter value to trigger the debug session|
|XDEBUG_LOG_PATH|`string`||xdebug.remote_log|The location of the xdebug log file, if it is blank the log is disabled|
|XDEBUG_PROFILE_ENABLE_TRIGGER|`1,0`|0|xdebug.profiler_enable_trigger|Enables the profiler and if necessary the XDebug extension|
|XDEBUG_PROFILE_TRIGGER_VALUE|`string`|DO_PROFILE|xdebug.profiler_enable_trigger_value|The POST/GET value to enable the profiler|
|XDEBUG_PROFILE_OUTPUT_DIR|`string`|/tmp|xdebug.profiler_output_dir|The path in the container to save the profiler files (probably should be a volume)|
|XDEBUG_PROFILE_OUTPUT_NAME|`string`|cachegrind.out.%t%s|xdebug.profiler_output_name|The pattern of the file name to save in the output directory|

## Container Directory Structure

### Apache DocumentRoot

`/var/www/html`

The document root of the VirtualHost for both the HTTP and HTTPS is mapped to /var/www/html.  You should be able to bind mount your code to HOST_PATH:/var/www/html and have the container serve up your content.

### Apache SSL Configuration

`/etc/httpd.certs`

The SSL enabled VirtualHost references the SSL certificate files in the /etc/httpd.certs directory.  The configuration references the files below.  By default the image has the localhost.* certificates that are copied into the directory, which I admit, isn't really that useful but it allows Apache to start without error AND have SSL enabled.  You can bind mount your own SSL certificate to /etc/httpd.certs and it will override the default behavior.

| Path | File |
|---|---|
|/etc/httpd.certs/server.crt|SSL Certificate File|
|/etc/httpd.certs/server.key|SSL Certificate Key|
|/etc/httpd.certs/ca.crt|SSL CA Certificate|

### Apache Logs

`/var/log/httpd`

The image symlinks access_log to /dev/stdout and error_log to /dev/stderr, both of these are located in the default CentOS Apache log directory (/var/log/httpd).  This will make `docker logs` work.  If you really want to separate the logs you can bind mount /var/log/httpd to your host, the result will be `docker logs` not producing output, but you will be able to tail just the access_log or error_log on your local host.

