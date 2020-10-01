# Docker Haul

![GitHub](https://img.shields.io/github/license/alanbchristie/docker-haul)
![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/alanbchristie/docker-haul)

[![CodeFactor](https://www.codefactor.io/repository/github/alanbchristie/docker-haul/badge)](https://www.codefactor.io/repository/github/alanbchristie/docker-haul)

A simple script that pulls all the container images from docker
for a user and namespace. Thanks to [Jerry Baker] and his
`dockerhub-v2-api-user.sh` [gist].

To run the script you will need: -

-   [jq]
-   docker
-   Credentials

Set your Docker credentials and the *namespace* of the container images
that you want to pull, remembering that the namespace does not have to be
the same as your username...

    $ export DOCKER_USERNAME=alanbchristie 
    $ export DOCKER_PASSWORD=*******
    $ export DOCKER_NAMESPACE=alanbchristie 

The pull (haul) the images...

    $ ./haul.sh

The script will force a pull by first removing each image.

>   Remember that you're pulling everything - so this may take some time,
    depending on what you're pulling.

If you don't want to keep the pulled images add `--no-keep` to the
command: -

    $ ./haul.sh --no-keep

---

[jerry baker]: https://gist.github.com/kizbitz
[gist]: https://gist.github.com/kizbitz/e59f95f7557b4bbb8bf2
[jq]: https://stedolan.github.io/jq
