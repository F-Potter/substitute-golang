package main

import (
	"fmt"
	"log"
	"net/http"
	"strings"
)
func input(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.Error(w, "404 not found.", http.StatusNotFound)
		return
	}

	switch r.Method {
	case "GET":		
		 http.ServeFile(w, r, "forms.html")
	case "POST":
		// Call ParseForm() to parse the raw query and update r.PostForm and r.Form.
		if err := r.ParseForm(); err != nil {
			fmt.Fprintf(w, "ParseForm() err: %v", err)
			return
		}
		// Substitute the message if it matches the replaces values
		message := r.FormValue("message")
		replacer := strings.NewReplacer("Oracle", "Oracle©", "Google", "Google©", "Microsoft", "Microsoft©", "Amazon", "Amazon©", "Deloitte", "Deloitte©")
		input := replacer.Replace(message)
		fmt.Fprintf(w, "%s\n", input)
	default:
		fmt.Fprintf(w, "Sorry, only GET and POST methods are supported.")
	}
}

func main() {
	http.HandleFunc("/", input)

	fmt.Printf("Starting server for testing HTTP POST...\n")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}