s2i for sbt
===

Created using s2i [v1.1.7](https://github.com/openshift/source-to-image/releases/tag/v1.1.7)

### create

Create the s2i image with

`#! SBT_VERSION=0.13.16 SCALA_VERSION=2.12.3 make`

### invoke

build an image tagged as `image-name`

`s2i build <path / url> sbt-s2i <image-name>`


### configuration

- `SBT_SUBPROJECT`; optional string that specifies the sbt subproject to build in (not needed if not multi-project)
- `plugins.sbt`; contains default set of sbt plugins that will be cached during the image build

### OpenShift Imagestream

An OpenShift Imagestream is provided that can be used in the OpenSHift console to build applications using this s2i image. To use it, simply add it as follows:

```
oc create -f sbt.yml
```

Note the openshift user must have rights to the openshift namespace (i.e. a cluster admin).

### SCALA Settings that need to be set to run in OpenShift

All of these settings can be configured in the scala project application.conf file

1. Set the PID ID to null
```
play.server.pidfile.path=/dev/null 
```

2. Set a Play Secret Key. 
```
play.http.secret.key="QCY?tAnfk?aZ?iwrNwnxIlR6CTf:G3gf:90Latabg@5241AB`R5W:1uDFN];Ik@n"
```
This should be a OCP ENV Secret at some point. 

3. Set the filters host. The code below will allow any host to access the project
```
play.filters.hosts {
  allowed = ["."]
}
```

### Trouble Shooting

Some times checking out this project in windows will cause ^M characters to appear on the s2i/bin git bash files cause a error while trying to run the assembly command. 

If that happens clean up the s2i/bin files by running

```
sed -e "s/^M//" filename > newfilename
``` 
