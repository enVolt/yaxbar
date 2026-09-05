package main

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/matryer/is"
	"github.com/matryer/xbar/pkg/plugins"
)

func TestMultiDirectoryPlugins(t *testing.T) {
	is := is.New(t)

	tempDir := t.TempDir()
	primaryDir := filepath.Join(tempDir, "yaxbar", "plugins")
	legacyDir := filepath.Join(tempDir, "xbar", "plugins")

	is.NoErr(os.MkdirAll(primaryDir, 0755))
	is.NoErr(os.MkdirAll(legacyDir, 0755))

	// Plugin in legacy dir
	legacyPlugin := filepath.Join(legacyDir, "legacy.10s.sh")
	is.NoErr(os.WriteFile(legacyPlugin, []byte("#!/bin/bash\necho legacy"), 0755))

	// Plugin in primary dir
	primaryPlugin := filepath.Join(primaryDir, "primary.10s.sh")
	is.NoErr(os.WriteFile(primaryPlugin, []byte("#!/bin/bash\necho primary"), 0755))

	// Overridden plugin in both
	overrideLegacy := filepath.Join(legacyDir, "shared.10s.sh")
	is.NoErr(os.WriteFile(overrideLegacy, []byte("#!/bin/bash\necho legacy_shared"), 0755))
	overridePrimary := filepath.Join(primaryDir, "shared.10s.sh")
	is.NoErr(os.WriteFile(overridePrimary, []byte("#!/bin/bash\necho primary_shared"), 0755))

	// Test multi-directory scanning with priority
	testDirs := []string{primaryDir, legacyDir}
	var allPlugins plugins.Plugins
	seen := make(map[string]bool)
	for _, dir := range testDirs {
		dirPlugins, err := plugins.Dir(dir)
		is.NoErr(err)
		for _, p := range dirPlugins {
			fn := filepath.Base(p.Command)
			if !seen[fn] {
				seen[fn] = true
				allPlugins = append(allPlugins, p)
			}
		}
	}

	is.Equal(len(allPlugins), 3) // primary, legacy, shared

	// Find the shared plugin and verify it came from primaryDir
	for _, p := range allPlugins {
		if filepath.Base(p.Command) == "shared.10s.sh" {
			is.Equal(filepath.Dir(p.Command), primaryDir)
		}
	}
}
