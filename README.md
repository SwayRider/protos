# protos

💬 This repository contains the `.proto` definitions for all SwayRider microservices.
Both gRPC and HTTP REST (via grpc-gateway) are supported.

## ✅ Structure

- `auth/v1/auth.proto`: Proto definition for the authentication service
- `third_party/googleapis/`: Git submodule containing official Google proto files (e.g. `annotations.proto`)

## 📦 Cloning this repository

Since this repository uses a Git submodule (`googleapis`), clone it as follows:

```bash
git clone --recurse-submodules https://<your-git-url>/swayrider/protos.git
```

If you already cloned the repo without submodules:

```bash
git submodule update --init --recursive
```

## ⚙️ Code Generation

This repository assumes you're generating Go code using:

- [`protoc`](https://grpc.io/docs/protoc-installation/)
- [`protoc-gen-go`](https://github.com/protocolbuffers/protobuf-go)
- [`protoc-gen-go-grpc`](https://github.com/grpc/grpc-go)
- [`protoc-gen-grpc-gateway`](https://github.com/grpc-ecosystem/grpc-gateway)
- [`protoc-gen-openapiv2`](https://github.com/grpc-ecosystem/grpc-gateway)

Install these tools with:

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest
```

### 🔧 Generate Code

Use the provided Makefile:

```bash
make gen
```

Or run `protoc` directly:

```bash
protoc -I . -I third_party/googleapis \
  --go_out=./gen/go \
  --go-grpc_out=./gen/go \
  --grpc-gateway_out=./gen/go \
  auth/v1/auth.proto
```

The generated code will be placed in `./gen/go`.
Your Go services can then import the generated packages like this:

To be added to go.mod:
```go
require hevanto-it.com/swayrider/protos v0.0.0

replace hevanto-it.com/swayrider/protos => ../protos/gen/go
```

And then in your code:

```go
import authv1 "hevanto-it.com/swayrider/protos/auth/v1"
```

## 📜 OpenAPI

The Makefile can also generate OpenAPI v2 specs (e.g., `auth.swagger.json`) based on your proto files.

## 🧱 Conventions

- All APIs follow semantic versioning in their paths: `auth/v1`, `user/v2`, etc.
- REST mapping is done via Google's `annotations.proto` (included as submodule)
- We follow a gRPC-first design philosophy; HTTP REST is optional and derived

## 🛠 Examples

If example clients or servers are provided, check the `examples/` folder or refer to linked services like `authservice`.
