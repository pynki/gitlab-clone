 XXXXXXXXX Clones all repositories in a gitlab installation

Needs a admin account to work as expected (clone all the repos). Did not test it with a normal account - should work as well but not clone all the repos on the server. The brutoforcing of the group ids will not beneccessary for non admin accounts think - so its quite stupid to use the script to not full clone the gitlab repos (no harm will be done but a lot 404's)

Config:

Your gitlab private token:

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
