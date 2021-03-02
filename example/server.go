package main

import (
	"fmt"
	"log"
	"net/http"
	_ "net/http/pprof"
)

func main() {
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal(err)
	}
}

func Add(a, b int) string {
	return fmt.Sprintf("%d + %d = %d", a, b, (a + b))
}
