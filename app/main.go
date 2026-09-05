package main

import (
	_ "embed"
	"fmt"
	"os"

	"github.com/pkg/errors"
	"github.com/wailsapp/wails/v2"
	"github.com/wailsapp/wails/v2/pkg/logger"
	"github.com/wailsapp/wails/v2/pkg/options"
	"github.com/wailsapp/wails/v2/pkg/options/mac"
)

//go:embed .version
var version string

func main() {
	println("YaxBar", version)
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "%s\n", err)
		os.Exit(1)
	}
	println("YaxBar exited")
}

func run() error {
	app, err := newApp()
	if err != nil {
		return errors.Wrap(err, "newApp")
	}
	wailsLogLevel := logger.ERROR
	app.Verbose = true
	if app.Verbose {
		wailsLogLevel = logger.DEBUG
	}
	err = wails.Run(&options.App{
		Title:             "YaxBar",
		Width:             1080,
		Height:            700,
		MinWidth:          800,
		MinHeight:         600,
		StartHidden:       true,
		HideWindowOnClose: true,
		Mac: &mac.Options{
			WebviewIsTransparent:          true,
			WindowBackgroundIsTranslucent: false,
			TitleBar:                      mac.TitleBarHiddenInset(),
			Menu:                          app.appMenu,
			ActivationPolicy:              mac.NSApplicationActivationPolicyAccessory,
			URLHandlers: map[string]func(string){
				// xbar://... and yaxbar://...
				"xbar":   app.handleIncomingURL,
				"yaxbar": app.handleIncomingURL,
			},
		},
		ContextMenus: app.contextMenus,
		LogLevel:     wailsLogLevel,
		Startup:      app.Start,
		Shutdown:     app.Shutdown,
		Bind: []interface{}{
			app.PersonService,
			app.CategoriesService,
			app.PluginsService,
			app.CommandService,
		},
	})
	if err != nil {
		return err
	}
	return nil
}
