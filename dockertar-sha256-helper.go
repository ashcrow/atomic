package main

import (
	"compress/gzip"
	"crypto/sha256"
	"fmt"
	"io"
	"os"
)

func main() {
	// Require one positional argument
	if len(os.Args) != 2 {
		panic("One positional argument is required")
	}
	reader, err := os.Open(os.Args[1])
	// Close the input file at the end of the function
	defer reader.Close()
	if err != nil {
		os.Exit(1)
	}
	buf := make([]byte, 4096)
	sha_256 := sha256.New()
	w := gzip.NewWriter(sha_256)
	// Close output file at the end of the function
	defer w.Close()

	for {
		n, err := reader.Read(buf)
		if n > 0 {
			w.Write(buf[:n])
		}
		if err == io.EOF {
			break
		}
		if err != nil {
			panic(err)
		}
	}
	fmt.Printf("%x\n", sha_256.Sum(nil))
}
