# RPC working principle
![远程过程调用流程图](https://astaxie.gitbooks.io/build-web-application-with-golang/en/images/8.4.rpc.png?raw=true)

Normally, an RPC call from client to server has the following ten steps:
1. Call the client handle, execute transfer arguments.
1. Call local system kernel to send network messages.
1. Send messages to remote hosts.
1. The server receives handle and arguments.
1. Execute remote processes.
1. Return execution result to corresponding handle.
1. The server handle calls remote system kernel.
1. Messages sent back to local system kernel.
1. The client handle receives messages from system kernel.
1. The client gets results from corresponding handle.