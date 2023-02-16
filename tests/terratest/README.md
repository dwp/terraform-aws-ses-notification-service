# Usage
The go libraries are compiled at the root folder of vpc module with below commands:

```
~/../vpc$ go mod init ses
~/../vpc$ go mod tidy
```


To run the tests execute the following:

```
~/../vpc/tests/terratest$ go test -v -timeout 30m ses_test.go
```
