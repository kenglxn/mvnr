## mvnr: recursive mvn command line tool

https://npmjs.org/package/mvnr

### Demo

![Demo](https://github.com/kenglxn/mvnr/raw/master/demo.gif)

### Install:

    sudo npm install -g mvnr

### Usage:

mvnr does not interpret any commands given to it, but simply ensures that commands are executed on any maven repository under the current working directory.
Any command you can pass to mvn, will work with mvnr. 

    mvnr clean install -DskipTests

mvnr does do a bit of dependency analysis before executing to ensure it builds the least dependent modules first. This means that if you have a module which has a dependency on another module which also resides under the current working directory (cwd), then mvnr will build the dependency first. It will also ignore poms in subdirectories where the parent directory contains a pom.

So the follwing structure:

<pre>
(cwd)
  ├── A
  │   └── B
  │       └── pom.xml   // depends on E & C
  ├── C
  │   ├── D
  │   │   └── pom.xml // child of C, will not be built explicitly, but is assumed to be a child module
  │   └── pom.xml 
  └── E
     └── pom.xml  // depends on C
</pre>

Will result in the build order:

1. C
2. E
3. B


### Building:

    git clone git://github.com/kenglxn/mvnr.git
    cd mvnr
    npm test

### License:

http://www.apache.org/licenses/LICENSE-2.0.html
