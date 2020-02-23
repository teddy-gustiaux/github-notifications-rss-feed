# GitHub Notifications RSS Feed

## Warning note

This project is in an **alpha** release stage.
It is not recommended for production usage. 

## What does it do?

This application generates an RSS feed from your GitHub notifications, that you can subscribe to in your favorite RSS reader application.

You no longer have to sort through all the notification emails GitHub is sending you- leverage the power of RSS!

## Prerequisites

Prerequisites:

- You will need to install Docker.
- You will need a [GitHub personal access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line#creating-a-token) to be able to use their API.

## Development

Steps:

- Clone this repository
- Setup your `.env` file (as per the `.env.template` file)
- You will have to build the Docker image for development once:

```
cd /path/to/github-notifications-rss-feed
make build_development
```

- Then you can edit the source code files.
Run the application with:

```
make run_development
```

## Self-hosting installation

In addition to the prerequisites of the previous, you will want to setup a cron job to run the application regularly.

For instance, setting up `crontab` to run it every 20 minutes:

```
*/20 * * * * cd /path/to/github-notifications-rss-feed && make run_production ENV_DIR=/path/to/.env OUTPUT_DIR=/path/to/output
```

For security reasons, use an user with minimum permissions.
You can also set up the command in a separate shell script.

- `ENV_DIR` must point to the folder containing your `.env` file.
- `OUTPUT_DIR` must point to the folder you would like to contain the generated RSS file.

You will want to serve your RSS file to the web (see below).
You can have the 
I recommend to store your `.env` file in a different location with appropriate permissions as it contains personal credentials which should not be shared.

Finally, setup a custom sub-domain to access the generate RSS feed.
I recommend [Let's Encrypt](https://letsencrypt.org/) to get a free TLS certificate.

You may also likely want to protect your endpoint.
Basic authentication is a quick and basic (pun intended) way to do this.
The web has many resources explaining [how](https://httpd.apache.org/docs/2.4/programs/htpasswd.html) to do [this](https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/).

Your Nginx configuration could look like this:

```
server {

    listen 80;
    server_name ghnrf.example.com;

    location / {
        return 301 https://ghnrf.example.com$request_uri;
    }

}

server {

    listen 443 ssl;
    server_name ghnrf.example.com;
    server_tokens off;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    auth_basic "Administrator's Area";
    auth_basic_user_file /path/to/my.htpasswd;

    ssl_certificate /etc/letsencrypt/live/ghnrf.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ghnrf.example.com/privkey.pem;

    root /path/to/output;

    location = /feed.xml {
        try_files /feed.xml =404;
    }

    location ^~ / {
        return 404;
    }

}
```

Your feed will be available at https://ghnrf.example.com/feed.xml once the application has run once. 

## Notes for Docker Toolbox on Windows 

If you are using Docker Toolbox on Windows, you may want to have your application files in a different directory than the default shared location.
In this case, once you have shared the appropriate folder in VirtualBox, the regular commands to run the application will fail.

The `Makefile` allows to pass up to 3 different parameters indicating where to find the files and folders the application needs to run.
All of them default to the current directory.

- ENV_DIR

If all parameters are the same, which is very likely if you are in a development environment, then you can copy the value of the first parameter to the others!

```
make run_development ENV_DIR=/path/to/github-notifications-rss-feed APP_DIR=$(ENV_DIR) OUTPUT_DIR=$(ENV_DIR)
```