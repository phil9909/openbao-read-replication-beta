# Read replication beta builds

This is a beta build of the `read-replication` branch.
Commit: [`{{.ShortCommit}}`](https://github.com/openbao/openbao/tree/{{.FullCommit}})

## Known Limitations

Read replication is still work in progress and therefore still has some limitations.
These are the known ones:

- PostgreSQL backend is not supported
- [Changes to auth mounts and secret mounts require restart of follower nodes](https://github.com/openbao/openbao/pull/1733)
- The [Remount API](https://openbao.org/api-docs/system/remount/) is untested and will probably cause problems. Restart of follower nodes is recommended.


## Installing

Either download a Linux Package:

- [DEB](https://github.com/phil9909/openbao-read-replication-beta/releases/download/v{{ .Version }}/bao_{{ .Version }}_linux_amd64.deb)
- [RPM](https://github.com/phil9909/openbao-read-replication-beta/releases/download/v{{ .Version }}/bao_{{ .Version }}_linux_amd64.rpm)
- [Arch](https://github.com/phil9909/openbao-read-replication-beta/releases/download/v{{ .Version }}/bao_{{ .Version }}_linux_amd64.pkg.tar.zst)

or use Docker/Podman: `ghcr.io/{{ .Env.GITHUB_REPOSITORY_OWNER }}/openbao-{{ .Branch }}-beta:{{ replace .Version "+" "-" }}-amd64`

Currently, the beta is only built for Linux amd64, get in touch if you need other OSs / Architectures.
