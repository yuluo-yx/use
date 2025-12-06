build:
	go build -o bin/app main.go

run:
	go run main.go

prod-run:
	./bin/app

prod: build prod-run
