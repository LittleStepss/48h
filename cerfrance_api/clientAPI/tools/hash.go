package tools

import (
	"crypto/sha256"
	"encoding/hex"
)

// HashPasswordSHA256 hashes a password using SHA-256 algorithm
func HashPasswordSHA256(password string) string {
	hash := sha256.New()
	hash.Write([]byte(password))
	return hex.EncodeToString(hash.Sum(nil))
}