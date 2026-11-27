include .env
export

export PROJECT_ROOT = $(CURDIR)

env-up:
	@docker compose up -d todoapp-postgres

env-stop:
	@docker compose stop todoapp-postgres

env-down:
	@docker compose down

env-config:
	@docker compose config


env-cleanup:
	@powershell -NoProfile -Command "$$answer = Read-Host 'Clean PostgreSQL data? This will delete database data. [y/N]'; if ($$answer -eq 'y') { docker compose down; if ($$LASTEXITCODE -eq 0) { Remove-Item -LiteralPath '.\out\pgdata' -Recurse -Force -ErrorAction SilentlyContinue; Write-Host 'Files cleaned' } } else { Write-Host 'Cancelled' }"

env-port-forwarder:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down port-forwarder

migrate-create:
	@powershell -NoProfile -Command "if ([string]::IsNullOrWhiteSpace('$(seq)')) { Write-Host 'Error: migration name is required.'; Write-Host 'Example: make migrate-create seq=init'; exit 1 }"
	docker compose run --rm todoapp-postgres-migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)"

migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down

migrate-action:
	@powershell -NoProfile -Command "if ([string]::IsNullOrWhiteSpace('$(action)')) { Write-Host 'Error: migration name is required.'; Write-Host 'Example: make migrate-action action=up'; exit 1 }"
	docker compose run --rm todoapp-postgres-migrate \
	    -path /migrations \
	    -database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable \
	    "$(action)"
