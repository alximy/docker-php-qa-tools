# Docker PHP QA Tools

## About

A docker image to run PHP common QA tools:

 - [composer-unused](https://github.com/composer-unused/composer-unused)
 - [jsonlint](https://github.com/Seldaek/jsonlint)
 - [parallel-lint](https://github.com/php-parallel-lint/PHP-Parallel-Lint)
 - [pdepend](http://pdepend.org/documentation/getting-started.html)
 - [phan](https://github.com/phan/phan)
 - [php-cs-fixer](https://github.com/FriendsOfPHP/PHP-CS-Fixer) (with `kubawerlos/php-cs-fixer-custom-fixers`)
 - [phpcs](https://github.com/squizlabs/PHP_CodeSniffer/wiki)
 - [phpdd](https://github.com/wapmorgan/PhpDeprecationDetector)
 - [phpinsights](https://phpinsights.com)
 - [phploc](https://github.com/sebastianbergmann/phploc)
 - [phpmd](https://github.com/phpmd/phpmd)
 - [phpmetrics](https://www.phpmetrics.org/index.html)
 - [phpmnd](https://github.com/povils/phpmnd)
 - [phpstan](https://phpstan.org/user-guide/getting-started) (with deprecation, dibi, doctrine, phpunit, beberlei-assert,
   strict-rules and symfony)
 - [twigcs](https://github.com/friendsoftwig/twigcs)
 - [yaml-lint](https://github.com/symfony/symfony/blob/6.0/src/Symfony/Component/Yaml/Command/LintCommand.php)

You can also install XDebug (not enabled) and AST PHP extensions.

## Usage

### Tags

Each major version of the build can change the default version of PHP, and
major versions of the tools, see the [build args section](#build-args) while
selecting the corresponding tag in this repository to know which ones are used.

|   Tag    |    Based image     |
|:--------:|:------------------:|
| 1-alpine | php:8.2-cli-alpine |
|    1     |    php:8.2-cli     |

Use the `latest` tag to target the most recent non-alpine release.

### With Docker

It uses the `PHP CLI` official image.

The first optional ARG is `PHP_VERSION` (default to 8.2):

```bash
docker build alximy/php-qa-tools:latest --tag my-qa-tools --build-arg WITH_COMPOSER_DEPS=1 \
    --build-arg PHP_VERSION=8.0 \
    --build-arg PHP_CS_FIXER_VERSION=^2 \
    --build-arg PHPSTAN_VERSION=^0
```

Then run inside your project:

```bash
docker run --rm --volume=`pwd`:/var/qa/ --workdir=/var/qa/ -- my-qa-tools CMD
```

where `CMD` can be any binary from the list above.
Use `--it -- my-qa-tools bash` if you need interaction.

To inherit from your custom PHP image, use the build arg `FROM_IMAGE`.
If the image does not have Composer you must use `WITH_COMPOSER_DEPS=1` as build
arg.

### With Docker Compose

Alternatively you can use `compose.yaml` or `compose-override.yaml`.
First, copy the [`Dockerfile`](/Dockerfile) or
[`Dockerfile.alpine`](/Dockerfile.alpine) and [`entrypoint.sh`](/entrypoint.sh)
from this repository in your project, let's say in `devops/qa/`, then add the
following to your configuration:

```yaml
services:
    # ...

    qa:
        container_name: ${COMPOSE_PROJECT_NAME}_qa
        build:
            dockerfile: ./devops/qa/Dockerfile
            args:
                PHP_VERSION: 8.0
                # Optionally inherit from the project PHP image
                #FROM_IMAGE: ${COMPOSE_PROJECT_NAME}_php
                #WITH_XDEBUG: 1
                #WITH_AST: 1
                #PHP_CS_FIXER_VERSION: ^2
                #PHPSTAN_VERSION: ^0

        # Add volumes and working dir according to your project:
        #volumes:
        #    - ./:/var/qa:rw,cached
        #working_dir: /var/qa
```

Then use it as:

```bash
docker compose run --rm qa CMD
```

or:

```bash
docker compose run --rm -it qa bash
```

### Build args

#### Customized `FROM`
 - `PHP_VERSION=8.2`
 - `FROM_IMAGE=php:${PHP_VERSION}-cli`

#### Installing Composer deps
Required if you don't inherit a PHP image with composer installed. They are not
installed by default.

 - `WITH_COMPOSER_DEPS=1`

#### Custom tools versions
Following versions are the defaults:
 - `COMPOSER_UNUSED_VERSION=^0.8`
 - `JSONLINT_VERSION=^1`
 - `PARALLEL_LINT_VERSION=^1`
 - `PDEPEND_VERSION=^2`
 - `PHAN_VERSION=^5`
 - `PHP_CS_FIXER_VERSION=^3`
 - `PHP_CODESNIFFER_VERSION=^3`
 - `PHP_DEPRECATION_DETECTOR_VERSION=^2`
 - `PHP_INSIGHTS_VERSION=^2`
 - `PHP_LOC_VERSION=^7`
 - `PHP_MD_VERSION=^2`
 - `PHP_METRICS_VERSION=^2`
 - `PHP_MND_VERSION=^3`
 - `PHPSTAN_VERSION=^1`
 - `TWIG_CS_VERSION=^6`
 - `YAML_LINTER_VERSION=^6`

#### Custom tools extensions:
 - `PHP_CS_FIXER_EXTENSIONS=""`
 - `PHP_CODESNIFFER_EXTENSIONS=""`
 - `PHPSTAN_EXTENSIONS=""`

Example: `--build-arg PHPSTAN_EXTENSIONS="my/phpstan-extension:*"`.

You can add many extensions separated by a space.

#### Installing PHP extensions
They are not installed by default:
 - `WITH_XDEBUG=1`
 - `WITH_AST=1`

XDebug is disabled by default when installed, to enable it use:
`ENABLE_XDEBUG=1` as build arg.

### Bonus

This image comes with `graphviz`, it will allow you to dump Symfony Workflows
using the `dot` command:

```bash
docker run --rm -it --volume=`pwd`:/var/qa/ --workdir=/var/qa/ -- \
    my-qa-tools \
    bash
```

Then, in the prompt:

```bash
bin/console workflow:dump my_workflow | dot -Tpng > var/my_workflow.png
```
