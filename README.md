Haraka Docker image
===================

[![Release](https://img.shields.io/github/v/release/instrumentisto/haraka-docker-image "Release")](https://github.com/instrumentisto/haraka-docker-image/releases)
[![CI](https://github.com/instrumentisto/haraka-docker-image/workflows/CI/badge.svg?branch=master "CI")](https://github.com/instrumentisto/haraka-docker-image/actions?query=workflow%3ACI+branch%3Amaster)
[![Docker Hub](https://img.shields.io/docker/pulls/instrumentisto/haraka?label=Docker%20Hub%20pulls "Docker Hub pulls")](https://hub.docker.com/r/instrumentisto/haraka)

[Docker Hub](https://hub.docker.com/r/instrumentisto/haraka)
| [GitHub Container Registry](https://github.com/orgs/instrumentisto/packages/container/package/haraka)
| [Quay.io](https://quay.io/repository/instrumentisto/haraka)

[Changelog](https://github.com/instrumentisto/haraka-docker-image/blob/master/CHANGELOG.md)




## Supported tags and respective `Dockerfile` links

- [`2.8.28-node16-r1`, `2.8.28`, `2.8`, `2`, `latest`][d1]




## What is Haraka?

[Haraka] is an open source [SMTP] server written in [Node.js] which provides extremely high performance coupled with a flexible plugin system allowing [Javascript] programmers full access to change the behaviour of the server.

> [haraka.github.io][Haraka]

> [github.com/haraka/Haraka](https://github.com/haraka/Haraka)

![Haraka Logo](https://haraka.github.io/logo-dark.svg "Haraka Logo") 




## How to use this image

To run [Haraka] mail server just start the container:
```bash
docker run -d -p 25:25 instrumentisto/haraka
```


### Configuration

By default, image uses default configuration files in `/etc/haraka/config/` directory. To use a custom configuration file you should mount it:
```bash
docker run -d -p 25:25 \
           -v /path/to/my/smtp.ini:/etc/haraka/config/smtp.ini:ro \
       instrumentisto/haraka
```


### Plugins

__Note!__ Once you've installed [Haraka plugins][1], do not forget to enable them in `/etc/haraka/config/plugins` file.

#### NPM packaged

[NPM packaged plugins][2] can be easily installed via `HARAKA_INSTALL_PLUGINS` environment variable. Specify it as comma-separated [NPM] packages, and the container will run `npm install` on its startup:
```bash
docker run -d -p 25:25 \
           -v /path/to/my/plugins:/etc/haraka/config/plugins:ro \
           -e HARAKA_INSTALL_PLUGINS=haraka-plugin-rcpt-postgresql,haraka-plugin-auth-enc-file@1.0 \
       instrumentisto/haraka
```

#### Legacy

Legacy custom plugin files may be mounted directly into `/etc/haraka/plugins` directory:
```bash
docker run -d -p 25:25 \
           -v /path/to/my-awesome-plugin.js:/etc/haraka/plugins/my-awesome-plugin.js:ro \
           -v /path/to/my/plugins:/etc/haraka/config/plugins:ro \
       instrumentisto/haraka
```




## Image tags

This image is based on the popular [Alpine Linux project][11], available in [the alpine official image][12]. Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

This variant is highly recommended when final image size being as small as possible is desired. The main caveat to note is that it does use [musl libc][13] instead of [glibc and friends][14], so certain software might run into issues depending on the depth of their libc requirements. However, most software doesn't have an issue with this, so this variant is usually a very safe choice. See [this Hacker News comment thread][15] for more discussion of the issues that might arise and some pro/con comparisons of using Alpine-based images.


### `X`

Latest tag of `X` [Haraka]'s major version.


### `X.Y`

Latest tag of `X.Y` [Haraka]'s minor version.


### `X.Y.Z`

Latest tag version of a concrete `X.Y.Z` version of [Haraka].


### `X.Y.Z-nodeA-rN`

Concrete `N` image revision tag of a [Haraka]'s concrete `X.Y.Z` version installed with `A` major version of [Node.js].

Once build, it's never updated.




## License

[Haraka] is licensed under [MIT license][91].

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

The [sources][92] for producing `instrumentisto/haraka` Docker images are licensed under [Blue Oak Model License 1.0.0][93].




## Issues

We can't notice comments in the [DockerHub] (or other container registries) so don't use them for reporting issue or asking question.

If you have any problems with or questions about this image, please contact us through a [GitHub issue][101].





[DockerHub]: https://hub.docker.com
[Javascript]: https://javascript.com
[Haraka]: https://haraka.github.io
[Node.js]: https://nodejs.org
[NPM]: https://www.npmjs.com
[SMTP]: https://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol

[1]: https://haraka.github.io/manual/Plugins.html
[2]: https://haraka.github.io/Plugins.html#installing-npm-packaged-plugins
[11]: http://alpinelinux.org
[12]: https://hub.docker.com/_/alpine
[13]: http://www.musl-libc.org
[14]: http://www.etalabs.net/compare_libcs.html
[15]: https://news.ycombinator.com/item?id=10782897
[91]: https://github.com/haraka/Haraka/blob/master/LICENSE
[92]: https://github.com/instrumentisto/haraka-docker-image
[93]: https://github.com/instrumentisto/haraka-docker-image/blob/master/LICENSE.md
[101]: https://github.com/instrumentisto/haraka-docker-image/issues

[d1]: https://github.com/instrumentisto/haraka-docker-image/blob/master/Dockerfile
