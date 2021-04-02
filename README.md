## proto-dump

proto-dump is a tool for recovering [Protobuf](https://code.google.com/p/protobuf/) descriptors (.proto files) from compiled programs. It can be thought of as [class-dump](http://stevenygard.com/projects/class-dump) for Protobuf.


## Updates

This fork has had the following small updates since being forked from [Sean Patrick O'Brien's](http://www.obriensp.com)
version at https://github.com/obriensp/proto-dump:

* included a version of Google Protobuf 2.5.0
* added patches to build the Google Protobuf and Command Line Utilities dependencies on recent macOS including Apple Silicon


An example use of ```proto-dump``` can be found at https://github.com/masaccio/numbers-parser for extracting protocol buffers from
Apple Numbers executables. In particular it appears necessary to pull all frameworks and dynamically loaded code into a single file
for ```proto-dump``` to extract. An example of this can be found in https://github.com/masaccio/numbers-parser/blob/master/protos/extract_protos.sh.


## Usage
```
	proto-dump 0.1
	Usage: proto-dump [-hv] [-o <output>] <input>
	  -h, --help                Show usage information and exit
	  -v, --version             Show version information
	  -o, --output=<output>     Write the .proto files to <output>
	  <input>                   Extract Protobuf descriptors from <input>
```
