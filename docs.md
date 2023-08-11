# Docs for davinci
Davinci is a pixelorama extension that allows you to create custom shaders.

# Installation
- Download the latest release.

- Drag it onto a running pixelorama application.

-  Go to Edit > Prefrences > Extensions > Davinci > Enable

# Reserved Keywords
Reserved keywords are special keywords used by Pixelorama / Davinci to pass data from the application your shader.
## selection
- This **uniform** is used to pass the selection map (the area of the image in selection).
- usage : ```uniform sampler2D selection;```

# Overrides
Davinci offsers overrides to customize you experience
- overide ui:
  - usage : ```--davinci-disable-ui```
