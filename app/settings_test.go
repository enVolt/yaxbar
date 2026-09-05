package main

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/matryer/is"
)

func TestSettings(t *testing.T) {
	is := is.New(t)

	t.Cleanup(func() {
		os.RemoveAll(filepath.Join("testdata", "settings.json"))
	})

	s, err := loadSettings(filepath.Join("testdata", "settings.json"))
	is.NoErr(err)
	s.AutoUpdate = true

	err = s.save()
	is.NoErr(err)

	s, err = loadSettings(filepath.Join("testdata", "settings.json"))
	is.NoErr(err)
	is.Equal(s.AutoUpdate, true)
}

func TestSettingsLegacyMigration(t *testing.T) {
	is := is.New(t)

	primaryPath := filepath.Join("testdata", "primary_settings.json")
	legacyPath := filepath.Join("testdata", "legacy_settings.json")

	t.Cleanup(func() {
		_ = os.RemoveAll(primaryPath)
		_ = os.RemoveAll(legacyPath)
	})

	legacySettings := &settings{
		path:       legacyPath,
		AutoUpdate: true,
	}
	legacySettings.Terminal.AppleScriptTemplate3 = "custom-applescript-template"
	err := legacySettings.save()
	is.NoErr(err)

	// Load with primary (missing) and legacy (present)
	s, err := loadSettings(primaryPath, legacyPath)
	is.NoErr(err)
	is.Equal(s.AutoUpdate, true)
	is.Equal(s.Terminal.AppleScriptTemplate3, "custom-applescript-template")

	// Verify that primary settings file was created
	_, err = os.Stat(primaryPath)
	is.NoErr(err)
}
