# Code Review — 2026-08-19

Security-focused review of the proto schema definitions (`protos/`). See [`Docs/REVIEW.md`](../../Docs/REVIEW.md) for how findings in this file are tracked and marked fixed.

No hand-modification of generated code was found — all `.pb.go`/`.pb.gw.go`/`_grpc.pb.go` files carry proper `Code generated` headers, and no hardcoded-secret patterns were found via grep. No Critical/High findings. The schemas are otherwise unremarkable: consistent versioning, no obvious injection vectors, and RPCs like `WhoIs`/`ChangeAccountType` correctly take opaque IDs rather than trusting client-supplied roles for response construction.

### 1. Plaintext credential fields carry no "sensitive" annotation

`auth/v1/auth.proto`: `LoginRequest.password`, `ChangePasswordRequest.old_password`/`new_password`, `ResetPasswordRequest.new_password`, `CreateAdminRequest.password`, `GetTokenRequest.client_secret`, `CreateServiceClientResponse.client_secret` are all plain `string` fields with no annotation marking them as sensitive. This is inherent to password-based auth over TLS-protected gRPC and not a flaw by itself, but nothing in the schema signals "redact from logs" — a service or gateway that logs full request/response protos via a generic interceptor would leak these. Worth a comment/lint convention (e.g. `google.api.field_behavior` or a naming convention feeding a redaction interceptor) rather than a proto bug. Severity: Low.

### 2. No size/length constraints anywhere in the schemas

None of the seven service protos (auth, mail, region, router, search, health) use `google.protobuf.field_behavior`, buf validate, or protoc-gen-validate annotations. Notably unbounded: `mail/v1/mail.proto` `SendRequest.to/cc/bcc` (repeated string, no cap) and `htmlBody`/`textBody` (unbounded string); `router/v1/router.proto` `RouteRequest.locations`/`exclude_locations`/`exclude_polygons` (unbounded waypoint/polygon lists feeding an external Valhalla call); `region/v1/region.proto` `FindRouteRegionPathsRequest.waypoints`. This pushes 100% of resource-exhaustion defense onto each service's handler code, with no schema-level backstop or documented contract. Adopting `buf.validate` (or equivalent) would close this gap platform-wide in one place instead of per-service. Severity: Info, systemic across all services.

### 3. No authorization metadata encoded in the schema

Admin-only RPCs (`CreateAdmin`, `ChangeAccountType`, `CreateServiceClient`, `InviteUser`, mail's `Send`/`SendTemplate`, etc.) are distinguished only by REST path convention (`/admin/...`) and comments, not by any proto option/annotation. Authz enforcement is entirely out-of-band (JWT claims checked in-service or at the gateway). Not a proto defect per se, but there's no compile-time or schema-visible guarantee an `/admin/*` RPC is actually gated — purely convention-based. Severity: Info.
