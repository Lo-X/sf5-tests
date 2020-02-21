# Installation

## Technical requirements

You will need to install:
* Php > 7.2.5
* [Composer](https://getcomposer.org/download/)
* [Symfony executable/command tool](https://symfony.com/download)

You can check if you have the requirements by executing this command in a terminal:

```bash
$ symfony check:requirements
```

## Create a new Symfony project

```bash
# '--full' installs a ful web application, don't use it for APIs, micrservices, etc.
$ symfony new my_project_name --full
$ cd my_project_name
```

## Run Symfony application without Apache/Nginx with Symfony (dev only)

```bash
$ symfony serve
```
