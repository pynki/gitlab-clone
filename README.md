Clones all repos in a gitlab installation

Config:

Your gitlab rivate token:

```shell
PRIVATE_TOKEN="InsertYourPrivateTokenHere"
```

Your Server address (eg. https://server.domain.net):

```shell
URI_BASE="https://server.domain.net"
```

The directory to clone the repos to:

```shell
CLONE_DIR="./gitlab-clone"
```

Clones running at the same time:

```shell
PARALLEL_CLONES=3
```

Expected maxmimal group id:

```shell
EXPECTED_MAX_GROUP_ID=150 
```

The script bruteforces all the group ids to find them. There seems to be no way to see all projects on agitlab server without bruteforcing them. `EXPECTED_MAX_GROUP_ID` was the number of groups * 2 in my case.

Clones into `CLONE_DIR` and creates a folder structure for groups and projects like this:

```
CLONE_DIR/
    groupName1/
		projectName1/
		projectName2/
	groupName2/
		projectName3/
		projectName4/
	...
```
