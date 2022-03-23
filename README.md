# Docker PHP QA Tools

## About

A docker image to run PHP common QA tools:

 - [composer-unused](https://github.com/composer-unused/composer-unused)
 - [jsonlint](https://github.com/Seldaek/jsonlint)
 - [parallel-lint](https://github.com/php-parallel-lint/PHP-Parallel-Lint)
 - [phpcpd](https://github.com/sebastianbergmann/phpcpd)
 - [pdepend](http://pdepend.org/documentation/getting-started.html)
 - [phan](https://github.com/phan/phan)
 - [php-cs-fixer](https://github.com/FriendsOfPHP/PHP-CS-Fixer)
 - [phpcs](https://github.com/squizlabs/PHP_CodeSniffer/wiki)
 - [phpdd](https://github.com/wapmorgan/PhpDeprecationDetector)
 - [phpinsights](https://phpinsights.com)
 - [phploc](https://github.com/sebastianbergmann/phploc)
 - [phpmd](https://github.com/phpmd/phpmd)
 - [phpmetrics](https://www.phpmetrics.org/index.html)
 - [phpmnd](https://github.com/povils/phpmnd)
 - [phpstan](https://phpstan.org/user-guide/getting-started) (with didi, doctrine, phpunit, beberlei-assert, strict-rules)
 - [twigcs](https://github.com/friendsoftwig/twigcs)
 - [yaml-lint](https://github.com/symfony/symfony/blob/6.0/src/Symfony/Component/Yaml/Command/LintCommand.php)

This also adds xdebug (not enabled) and ast PHP extensions.

## Usage

### From `php:cli`

The required ARG is `PHP_VERSION`:

```bash
$ docker build alximy:php-qa-tools --tag qa --build-arg PHP_VERSION=8.1
```

Then run

```bash
docker run --rm --volume=`pwd`:/var/qa/ --working-dir=/var/qa/ -- qa CMD
```

where `CMD` can be any binary from the list above, or `--it -- qa bash` if you
need interaction.


### From project PHP based image

Alternatively you can use `docker-compose.yml` or `docker-composer.override.yml`:

```yaml
version: '3'

services:
    # ...

    qa:
        container_name: ${COMPOSE_PROJECT_NAME}_qa
        image: alximy:php-qa-tools
        build:
            args:
                PHP_VERSION: 8.1
                # Optionally inherit from the project PHP image
                #FROM_IMAGE: ${COMPOSE_PROJECT_NAME}_php

        # Add volumes and working dir according to your project:
        #volumes:
        #    - ./:/srv/app:rw,cached
        #working_dir: /srv/app
```

Then use it as:

```bash
docker-compose run --rm qa CMD
```

or:

```bash
docker-compose run --rm -it qa bash
```
