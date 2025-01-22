repo := "ghcr.io/development-containers"
podman := `nu -c "if ((podman --version | parse --regex '([a-zA-Z ]*)(?<major>\d)\..*'| get major.0 | into int) >= 5) {print 'podman'} else { print 'docker'}"`

warn := if podman != "podman" {`echo "WARNING: Yikes! That's an old OLD operating system you go there. Please upgrade to something wiht podman 5. Falling back to docker." >&2`} else {""}

_default:
    @just --list


_run name:
    {{podman}} run --rm -it {{repo}}/{{name}}

# Build the container that has all our custom software in /opt
_build_opt:
     {{podman}} build -t opt -f containerfiles/opt.Containerfile .

_build name: (_build_opt)
     {{podman}} build -t {{repo}}/{{name}} -f containerfiles/{{name}}.Containerfile .

_push name:
    {{podman}} push {{repo}}/{{name}}


build_and_push name: (_build name) (test name) (_push name)


# build and enter a container
try name: (_build name) (_run name)


# run a command in a new container
_run_command name cmd:
    {{podman}} run --entrypoint 'bash' --rm {{repo}}/{{name}} -l -c '{{cmd}}'

# build image and run some smoketests against it
test name: (_build name) (_run_command name 'set -xeuo pipefail; for script in /examples/tests/*; do "$script"; done') 

# clean up docker cache
clear_docker_cache:
    docker image prune -f
    docker builder prune -f
