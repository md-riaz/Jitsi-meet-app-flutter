# Step 2-5 Progress (Flutter + Backend API)

## Step 2 — Guest invite flow
- [x] Added invite token field in Join sheet
- [x] Added API calls: resolve invite, accept invite
- [x] Added guest join with invite token support

## Step 3 — Admission polling UI
- [x] Added admission-status API endpoint on backend (`/api/v1/meetings/{id}/admission-status`)
- [x] Added polling flow in app when `ERR_ADMISSION_REQUIRED`
- [x] Added pending/rejected handling messages

## Step 4 — Automated API tests
- [x] Added Postman collection: `docs/API_V1.postman_collection.json`
- [ ] Add PHPUnit feature tests for v1 endpoints (next pass)

## Step 5 — Screenshot/doc refresh
- [x] Updated API docs for v1 + admission-status
- [x] Updated screenshot map with pending captures
- [x] Updated Flutter README integration notes
