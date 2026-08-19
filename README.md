# protos

💬 This repository contains the `.proto` definitions for all SwayRider microservices.
Both gRPC and HTTP REST (via grpc-gateway) are supported.

## ✅ Structure

- `auth/v1/auth.proto`: Proto definition for the authentication service
- `health/v1/health.proto`: Proto definition for the health-check service
- `mail/v1/mail.proto`: Proto definition for the transactional email service
- `region/v1/region.proto`: Proto definition for spatial region queries and border crossings
- `router/v1/router.proto`: Proto definition for cross-border route planning
- `search/v1/search.proto`: Proto definition for geocoding search
- `common_types/geo/geo.proto`: Shared geo types (coordinates, bounding boxes) used across service protos
- `third_party/googleapis/`: Vendored copy of official Google proto files (e.g. `annotations.proto`), fetched by the Makefile — not a git submodule (see below)

## 📦 Setting up `third_party/googleapis`

`third_party/googleapis` is not tracked in this repo or as a git submodule — it's fetched automatically by the Makefile's `fetch-googleapis` target, which clones `googleapis/googleapis` and checks out the commit pinned in `.googleapis.commit`. Just run:

```bash
make
```

and it will be fetched (or updated to the pinned commit) before code generation runs.

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
make
```

The `all`/`protos` target regenerates every service in one pass (`proto-auth`, `proto-health`, `proto-mail`, `proto-region`, `proto-router`, `proto-search`) plus the shared `common_types/geo/geo.proto` (via the `common_types` target), then runs `go mod tidy`. Run a single service's target directly (e.g. `make proto-auth`) to regenerate just that one.

Or run `protoc` directly:

```bash
protoc -I . -I third_party/googleapis \
  -I /usr/local/include \
  --go_out=paths=source_relative:. \
  --go-grpc_out=paths=source_relative:. \
  --grpc-gateway_out=paths=source_relative:. \
  auth/v1/auth.proto
```

Generated Go files are placed next to their `.proto` source files (e.g. `auth/v1/auth.pb.go`).
Your Go services can then import the generated packages like this:

To be added to go.mod:
```go
require github.com/swayrider/protos v0.0.0

replace github.com/swayrider/protos => ../protos
```

And then in your code:

```go
import authv1 "github.com/swayrider/protos/auth/v1"
```

## 📜 OpenAPI

The Makefile can also generate OpenAPI v2 specs (e.g., `auth.swagger.json`) based on your proto files.

## 🧱 Conventions

- All APIs follow semantic versioning in their paths: `auth/v1`, `user/v2`, etc.
- REST mapping is done via Google's `annotations.proto` (included as submodule)
- We follow a gRPC-first design philosophy; HTTP REST is optional and derived

## 🛠 Examples

If example clients or servers are provided, check the `examples/` folder or refer to linked services like `authservice`.
