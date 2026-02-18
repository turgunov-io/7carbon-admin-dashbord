{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    // Force local CanvasKit resources instead of external CDN.
    canvasKitBaseUrl: 'canvaskit/',
  },
});
